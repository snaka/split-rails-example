# Create sample users
user1 = User.create!(
  email: "test@example.com",
  password: "password",
  password_confirmation: "password"
)

user2 = User.create!(
  email: "demo@example.com",
  password: "password",
  password_confirmation: "password"
)

# Create sample todos for user1
user1.todos.create!(
  title: "Complete Rails application",
  description: "Finish implementing the todo app with authentication and A/B testing",
  priority: 1,
  completed: false
)

user1.todos.create!(
  title: "Write documentation",
  description: "Create README with setup instructions",
  priority: 2,
  completed: false
)

user1.todos.create!(
  title: "Setup CI/CD pipeline",
  description: "Configure GitHub Actions for automated testing",
  priority: 3,
  completed: false
)

user1.todos.create!(
  title: "Review Split gem dashboard",
  description: "Check A/B test results and analytics",
  priority: 2,
  completed: true
)

# Create sample todos for user2
user2.todos.create!(
  title: "Learn Ruby on Rails",
  description: "Complete online tutorial series",
  priority: 1,
  completed: false
)

user2.todos.create!(
  title: "Deploy to production",
  description: "Deploy application to Heroku or Railway",
  priority: 4,
  completed: false
)

puts "Seed data created successfully!"
puts "You can login with:"
puts "  Email: test@example.com, Password: password"
puts "  Email: demo@example.com, Password: password"