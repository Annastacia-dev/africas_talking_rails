require 'faker'

# Clear existing data
puts 'Clearing existing data...'
User.destroy_all

# Generate 10 users
puts 'Generating seed data...'
10.times do
  name = Faker::Name.name
  # Generate a random 8-digit number
  random_number = rand(10_000_000..99_999_999)
  # Concatenate the number with the Kenyan country code (254) and the '7' prefix
  phone_number = "2547#{random_number}"

  User.create!(
    name: name,
    phone_number: phone_number
  )
end

puts "Generated #{User.count} users."

