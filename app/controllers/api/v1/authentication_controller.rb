class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [ :login, :register, :forgot_password, :reset_password ]

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

  # POST /api/v1/auth/register
  def register
    @user = User.new(user_params)

    if @user.save
      token = JwtService.encode(user_id: @user.id)
      render json: {
        token: token,
        user: { id: @user.id, name: @user.name, email: @user.email, role: @user.role }
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/auth/logout
  def logout
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    begin
      decoded = JwtService.decode(token)
      TokenBlacklist.create!(jti: decoded[:jti], exp: Time.at(decoded[:exp]))
      render json: { message: "Logged out successfully" }, status: :ok
    rescue => e
      render json: { error: "Invalid token" }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/auth/forgot_password
  def forgot_password
    @user = User.find_by(email: params[:email])

    if @user
      @user.generate_reset_password_token!
      # TODO: Send email with reset link in production
      # UserMailer.reset_password(@user).deliver_later

      render json: {
        message: "Reset password instructions sent to your email",
        reset_token: @user.reset_password_token  # Only for development/testing
      }, status: :ok
    else
      render json: { error: "Email not found" }, status: :not_found
    end
  end

  # POST /api/v1/auth/reset_password
  def reset_password
    @user = User.find_by(reset_password_token: params[:token])

    if @user && @user.password_token_valid?
      @user.reset_password!(params[:password])
      render json: { message: "Password reset successfully" }, status: :ok
    else
      render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :role)
  end
end
