class CallbacksController < Devise::OmniauthCallbacksController
    def facebook
        p request.env["omniauth.auth"]
        p "Parsing"
        p JSON.parse(request.env["omniauth.auth"].to_json)
        redirect_to signin_path
    end

    def google_oauth2
        p request.env["omniauth.auth"]
        p "Parsing"
        p JSON.parse(request.env["omniauth.auth"].to_json)
        redirect_to signin_path
    end

    def twitter
        p request.env["omniauth.auth"]
        p "Parsing"
        p JSON.parse(request.env["omniauth.auth"].to_json)
        redirect_to signin_path
    end

    def gogli
        @user = User.from_omniauth(request.env["omniauth.auth"])
        @user.username = request.env["omniauth.auth"].info.name
        if @user.save
            sign_in_and_redirect @user
        end
    end
end