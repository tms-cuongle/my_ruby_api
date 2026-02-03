class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  enum :role, { admin: 0, ref: 1, edit: 2 }, default: :ref

  # Generate reset password token
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  # Check if reset token is still valid (expires after 2 hours)
  def password_token_valid?
    return false if reset_password_sent_at.nil?
    (reset_password_sent_at + 2.hours) > Time.current
  end

  # Reset password with token
  def reset_password!(new_password)
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    self.password = new_password
    save!
  end
end
