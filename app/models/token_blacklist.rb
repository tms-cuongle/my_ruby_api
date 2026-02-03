class TokenBlacklist < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true

  def self.cleanup_expired
    where("exp < ?", Time.current).delete_all
  end

  def self.blacklisted?(jti)
    exists?(jti: jti)
  end
end
