# Todo App with A/B Testing

A Rails 8 todo application featuring user authentication and A/B testing capabilities using the Split gem.

## Features

- User authentication (signup/login)
- Todo CRUD operations
- A/B testing integration with Split dashboard
- Redis-backed experiment tracking

## Requirements

* Ruby 3.2.0 or higher
* Rails 8.0.2+
* SQLite 3
* Redis (for A/B testing)
* Bundler

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd todo_app
```

2. Install dependencies:
```bash
bundle install
```

3. Setup the database:
```bash
rails db:create
rails db:migrate
rails db:seed # if seed data is available
```

4. Start Redis server (required for A/B testing):
```bash
redis-server
```

## Running the Application

1. Start the Rails server:
```bash
rails server
# or
bin/rails s
```

2. Access the application at `http://localhost:3000`

## Usage

### User Authentication

1. **Sign Up**: Navigate to `/signup` to create a new account
2. **Log In**: Navigate to `/login` to sign in with your credentials
3. **Log Out**: Click the logout link when signed in

### Managing Todos

1. **View Todos**: Access your todo list at the root path (`/`)
2. **Create Todo**: Click "New Todo" and fill in the details
3. **Edit Todo**: Click "Edit" next to any todo item
4. **Delete Todo**: Click "Delete" to remove a todo
5. **Mark Complete**: Toggle the completion status of todos

### A/B Testing Dashboard

Access the Split dashboard at `/split` to:
- View active experiments
- Monitor conversion rates
- Manage A/B test variations
- Analyze user behavior patterns

## Development

### Running Tests

```bash
# Run all tests
rails test

# Run system tests
rails test:system
```

### Linting

```bash
# Run RuboCop for code style checking
bundle exec rubocop
```

### Console Access

```bash
rails console
# or
bin/rails c
```

## Configuration

### Environment Variables

Create a `.env` file or set these environment variables:

- `REDIS_URL`: Redis connection URL (default: `redis://localhost:6379`)
- `RAILS_MASTER_KEY`: Required for production deployment

### A/B Testing Configuration

Split experiments can be configured in:
- `config/initializers/split.rb` (if present)
- Directly through the Split dashboard

## Docker Deployment

This application includes Docker and Kamal configuration for containerized deployment.

### Build Docker Image

```bash
docker build -t todo_app .
```

### Deploy with Kamal

```bash
kamal setup
kamal deploy
```

## API Endpoints

- `GET /todos` - List all todos
- `POST /todos` - Create a new todo
- `GET /todos/:id` - Show a specific todo
- `PATCH /todos/:id` - Update a todo
- `DELETE /todos/:id` - Delete a todo
- `GET /users/new` - User registration form
- `POST /users` - Create user account
- `GET /login` - Login form
- `POST /login` - Authenticate user
- `DELETE /logout` - End user session

## Monitoring

- **Health Check**: `GET /up` - Returns 200 if application is healthy
- **Split Dashboard**: `/split` - Monitor A/B testing metrics

## Troubleshooting

### Redis Connection Issues

If you encounter Redis connection errors:
1. Ensure Redis is running: `redis-cli ping`
2. Check Redis URL configuration
3. Verify firewall/network settings

### Database Issues

```bash
# Reset database (WARNING: destroys all data)
rails db:drop db:create db:migrate
```

### Asset Compilation Issues

```bash
# Precompile assets
rails assets:precompile
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

[Specify your license here]
