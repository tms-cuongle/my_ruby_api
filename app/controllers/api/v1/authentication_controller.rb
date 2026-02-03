class Api::V1::AuthenticationController < ApplicationController
  # POST /api/v1/auth/login
  def login
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      token = JwtService.encode(user_id: @user.id)
      time = 24.hours.from_now
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     name: @user.name, role: @user.role }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
