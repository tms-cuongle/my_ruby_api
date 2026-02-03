class ApplicationController < ActionController::API
  def authorize_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    begin
      @decoded = JwtService.decode(header)
      @current_user = User.find(@decoded[:user_id]) if @decoded
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def authorize_admin!
    render json: { error: "Forbidden" }, status: :forbidden unless @current_user&.admin?
  end

  def authorize_edit!
    render json: { error: "Forbidden" }, status: :forbidden unless @current_user&.admin? || @current_user&.edit?
  end

  attr_reader :current_user
end
