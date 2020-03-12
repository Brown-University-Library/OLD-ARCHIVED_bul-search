class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      if params && params["target"] != nil
        sign_in @user, :event => :authentication
        set_flash_message(:notice, :success, :kind => "Shibboleth") if is_navigational_format?
        redirect_to params["target"]
      else
        sign_in @user, :event => :authentication
        set_flash_message(:notice, :success, :kind => "Shibboleth") if is_navigational_format?
        redirect_to "/"
      end
    else
      session["devise.shibboleth_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
