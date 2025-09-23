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

# Create public todos for demonstration
Todo.create!(
  title: "Welcome to our Todo App",
  description: "This is a sample public todo that everyone can see",
  priority: 1,
  completed: false,
  public: true,
  user: user1
)

Todo.create!(
  title: "Check out our A/B testing features",
  description: "This app demonstrates Split gem integration for A/B testing",
  priority: 2,
  completed: false,
  public: true,
  user: user1
)

Todo.create!(
  title: "Join our community",
  description: "Sign up to create your own todos and join the community",
  priority: 3,
  completed: false,
  public: true,
  user: user2
)

puts "Seed data created successfully!"
puts "You can login with:"
puts "  Email: test@example.com, Password: password"
puts "  Email: demo@example.com, Password: password"