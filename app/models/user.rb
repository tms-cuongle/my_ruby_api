class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  enum :role, { admin: 0, ref: 1, edit: 2 }, default: :ref
end
