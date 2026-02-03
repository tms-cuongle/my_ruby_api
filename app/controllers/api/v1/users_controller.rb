class Api::V1::UsersController < ApplicationController
  before_action :authorize_request
  before_action :set_user, only: %i[ show update destroy ]
  before_action :authorize_admin!, only: %i[ destroy ]
  before_action :authorize_edit!, only: %i[ create update ]

  # GET /api/v1/users
  def index
    @users = User.all
    render json: @users.map { |user| user_response(user) }
  end

  # GET /api/v1/users/1
  def show
    render json: user_response(@user)
  end

  # POST /api/v1/users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/users/1
  def destroy
    @user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :name, :email, :avatar_url, :password, :role ])
    end

    # Format user response with avatar URL
    def user_response(user)
      {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar_url: user.avatar.attached? ? Rails.application.routes.url_helpers.url_for(user.avatar) : nil,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end
end
