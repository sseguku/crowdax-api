# Seed default users for development/testing
users = [
  {
    email: 'admin@example.com',
    password: 'password123',
    role: 'admin',
    first_name: 'Admin',
    last_name: 'User'
  },
  {
    email: 'test@example.com',
    password: 'password123',
    role: 'entrepreneur',
    first_name: 'Test',
    last_name: 'Entrepreneur'
  },
  {
    email: 'investor@example.com',
    password: 'password123',
    role: 'investor',
    first_name: 'Test',
    last_name: 'Investor'
  },
  {
    email: 'visitor@example.com',
    password: 'password123',
    role: 'visitor',
    first_name: 'Test',
    last_name: 'Visitor'
  }
]

users.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  user.assign_attributes(attrs)
  user.confirmed_at = Time.current
  user.save!
end

puts 'Seeded default users: admin, entrepreneur, investor, visitor.'
