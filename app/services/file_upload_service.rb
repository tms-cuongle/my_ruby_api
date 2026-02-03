class FileUploadService
  MAX_FILE_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  def self.upload(file)
    new(file).upload
  end

  def initialize(file)
    @file = file
  end

  def upload
    validate_file!

    blob = ActiveStorage::Blob.create_and_upload!(
      io: @file.tempfile,
      filename: @file.original_filename,
      content_type: @file.content_type
    )

    {
      success: true,
      url: url_for_blob(blob),
      filename: blob.filename.to_s,
      size: blob.byte_size,
      content_type: blob.content_type
    }
  rescue StandardError => e
    {
      success: false,
      error: e.message
    }
  end

  private

  def validate_file!
    raise "File is required" if @file.nil?
    raise "File size exceeds #{MAX_FILE_SIZE / 1.megabyte}MB limit" if @file.size > MAX_FILE_SIZE
    raise "File type not allowed. Allowed types: #{ALLOWED_CONTENT_TYPES.join(', ')}" unless ALLOWED_CONTENT_TYPES.include?(@file.content_type)
  end

  def url_for_blob(blob)
    if Rails.application.config.active_storage.service == :amazon
      blob.url
    else
      Rails.application.routes.url_helpers.rails_blob_url(blob, host: default_url_options[:host])
    end
  end

  def default_url_options
    {
      host: ENV["APP_HOST"] || "localhost:3000",
      protocol: Rails.env.production? ? "https" : "http"
    }
  end
end
