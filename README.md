# Split Rails Example

A Rails 8 todo application demonstrating A/B testing capabilities using the Split gem.

## Features

- User authentication (signup/login)
- Todo CRUD operations
- A/B testing integration with Split dashboard

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Setup the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. Start Redis server (required for A/B testing):
```bash
redis-server
```

4. Start the Rails server:
```bash
rails server
```

5. Access the application at `http://localhost:3000`

## Sample Users

After running `rails db:seed`, you can login with:

- **Email**: `test@example.com` / **Password**: `password`
- **Email**: `demo@example.com` / **Password**: `password`

## A/B Testing Dashboard

Access the Split dashboard at `/split` to:
- View active experiments
- Monitor conversion rates
- Manage A/B test variations

### Authentication

- **URL**: `/split`
- **Username**: `admin`
- **Password**: `secret`

## Scripts

For additional utilities and testing scripts, see [scripts/README.md](scripts/README.md).
