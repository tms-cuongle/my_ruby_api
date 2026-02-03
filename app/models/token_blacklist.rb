class TokenBlacklist < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true

  # Cleanup expired tokens
  def self.cleanup_expired
    where("exp < ?", Time.current).delete_all
  end

  # Check if token is blacklisted
  def self.blacklisted?(jti)
    exists?(jti: jti)
  end
end
