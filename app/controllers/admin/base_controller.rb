class Admin::BaseController < ApplicationController
  layout 'admin'

  before_filter :require_login_or_enki_hash

  protected

  def salt
    @@salt ||= Digest::SHA1.hexdigest(File.open("#{RAILS_ROOT}/config/database.yml").read + File.open(Enki::Config.default_location).read + RAILS_ENV)
  end

  def hash_request(request)
    Digest::SHA1.hexdigest(request.raw_post.to_s + salt)
  end

  def require_login_or_enki_hash
    unless session[:logged_in] || request.headers['HTTP_X_ENKIHASH'] == hash_request(request)
      return render(:text => false.to_yaml, :status => :forbidden) if params[:format] == 'yaml'
      return redirect_to(admin_session_path)
    end
  end

  def set_content_type
    headers['Content-Type'] ||= 'text/html; charset=utf-8'
  end

  def translate_yaml(yaml)
    ret = YAML.load(yaml)
    raise("Invalid request: YAML must specify a hash") unless ret.is_a?(Hash)
    ret
  end

  def translate_params  
    params.update(translate_yaml(request.raw_post)) if params[:format] == 'yaml'
  end
end
