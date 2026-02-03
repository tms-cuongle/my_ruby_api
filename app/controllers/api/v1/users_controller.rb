class Api::V1::UsersController < ApplicationController
  before_action :authorize_request
  before_action :set_user, only: %i[ show update destroy ]
  before_action :authorize_admin!, only: %i[ destroy ]
  before_action :authorize_edit!, only: %i[ create update ]

  def index
    @users = User.all
    render json: @users.map { |user| user_response(user) }
  end

  def show
    render json: user_response(@user)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
  end

  def upload_avatar
    unless params[:file].present?
      return render json: { error: "File is required" }, status: :bad_request
    end

    result = FileUploadService.upload(params[:file])

    if result[:success]
      @current_user.avatar.attach(
        io: File.open(params[:file].tempfile),
        filename: params[:file].original_filename,
        content_type: params[:file].content_type
      )

      avatar_url = if @current_user.avatar.attached?
        Rails.application.routes.url_helpers.rails_blob_url(
          @current_user.avatar,
          host: request.base_url
        )
      else
        nil
      end

      render json: {
        message: "Avatar uploaded successfully",
        avatar_url: avatar_url
      }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.expect(user: [ :name, :email, :avatar_url, :password, :role ])
  end

  def user_response(user)
    avatar_url = if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(
        user.avatar,
        host: request.base_url
      )
    else
      nil
    end

    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      avatar_url: avatar_url,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
