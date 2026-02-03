# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample users
users = [
  { name: "Alice Admin", email: "admin@example.com", role: :admin, password: "password123" },
  { name: "Bob Ref", email: "ref@example.com", role: :ref, password: "password123" },
  { name: "Charlie Edit", email: "edit@example.com", role: :edit, password: "password123" }
]

users.each do |user_data|
  User.find_or_initialize_by(email: user_data[:email]).tap do |user|
    user.name = user_data[:name]
    user.role = user_data[:role]
    user.password = user_data[:password]
    user.save!
  end
end

puts "Seed: Created/Updated #{User.count} users with roles."
