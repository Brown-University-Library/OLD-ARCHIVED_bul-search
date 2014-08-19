class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    logger.debug("omniauth.auth: #{request.env['omniauth.auth']}")
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, :envent => :authentication
      set_flash_message(:notice, :success, :kind => "Shibboleth") if is_navigational_format?
    else
      session["devise.shibboleth_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
