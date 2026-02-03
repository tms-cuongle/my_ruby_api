class Api::V1::UploadsController < ApplicationController
  before_action :authorize_request

  # POST /api/v1/uploads
  def create
    unless params[:file].present?
      return render json: { error: 'File is required' }, status: :bad_request
    end

    result = FileUploadService.upload(params[:file])

    if result[:success]
      render json: { url: result[:url] }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end
