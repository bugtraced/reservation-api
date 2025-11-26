# Reservation API

A robust RESTful API built with Ruby on Rails 8.1 for managing customer reservations, vehicle information, and time slot bookings. This API provides comprehensive validation, conflict detection, and efficient query handling.

## Features

- Complete CRUD operations for customers, vehicles, and reservations
- Conflict detection prevents overlapping reservations for the same vehicle
- Comprehensive validations for email format, phone numbers, date ranges, and business rules
- N+1 query prevention with Bullet gem for optimal database performance
- Rubocop configured with Rails Omakase standards
- Full test coverage with unit tests for models and integration tests for controllers

## Prerequisites

- Ruby 3.0 or higher
- PostgreSQL 9.3 or higher (must be running)
- Bundler gem

## Quick Start

### 1. Install Dependencies

```bash
bundle install
```

### 2. Setup Database

Make sure PostgreSQL is running, then:

```bash
rails db:create
rails db:migrate
```

### 3. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Customers

GET `/customers` - List all customers
GET `/customers/:id` - Get customer details
POST `/customers` - Create new customer
PATCH/PUT `/customers/:id` - Update customer
DELETE `/customers/:id` - Delete customer

Request body example:
```json
{
  "customer": {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "123-456-7890"
  }
}
```

### Vehicles

GET `/vehicles` - List all vehicles
GET `/vehicles?customer_id=1` - Filter by customer
GET `/vehicles/:id` - Get vehicle details
POST `/vehicles` - Create new vehicle
PATCH/PUT `/vehicles/:id` - Update vehicle
DELETE `/vehicles/:id` - Delete vehicle

Request body example:
```json
{
  "vehicle": {
    "make": "Toyota",
    "model": "Camry",
    "year": 2020,
    "color": "Blue",
    "license_plate": "ABC123",
    "customer_id": 1
  }
}
```

### Reservations

GET `/reservations` - List all reservations
GET `/reservations?customer_id=1` - Filter by customer
GET `/reservations?vehicle_id=1` - Filter by vehicle
GET `/reservations?upcoming=true` - Get upcoming reservations
GET `/reservations/:id` - Get reservation details
POST `/reservations` - Create new reservation
PATCH/PUT `/reservations/:id` - Update reservation
DELETE `/reservations/:id` - Delete reservation

Request body example:
```json
{
  "reservation": {
    "customer_id": 1,
    "vehicle_id": 1,
    "start_time": "2024-12-01T10:00:00Z",
    "end_time": "2024-12-01T12:00:00Z",
    "status": "pending"
  }
}
```

Status values: `pending`, `confirmed`, `cancelled`, `completed`

## Testing

### Run All Tests

```bash
rails test
```

### Run Specific Test Suites

```bash
rails test test/models              # Model tests
rails test test/controllers          # Controller tests
rails test test/models/customer_test.rb  # Specific file
```

### Test Coverage

The test suite includes:
- Model validations and associations
- Controller CRUD operations
- Business logic validation
- Error handling and edge cases
- Reservation conflict detection
- Filtering and scoping

Expected output:
```
Running 30+ tests covering:
- Customer model (10 tests)
- Vehicle model (8 tests)
- Reservation model (12 tests)
- All controller endpoints (15+ tests)
```

## Code Quality

### Rubocop

Check and auto-fix code style:

```bash
bundle exec rubocop          # Check violations
bundle exec rubocop -a       # Auto-correct
```

### Bullet (N+1 Detection)

Bullet automatically detects N+1 queries in development and test environments:
- Browser console alerts (development)
- Rails log warnings
- Unused eager loading notifications

All controllers use `includes()` to prevent N+1 queries.

## Data Models

### Customer
```ruby
name: string (2-100 chars, required)
email: string (unique, valid format, required)
phone: string (valid format, required)

Relationships:
- has_many :vehicles
- has_many :reservations
```

### Vehicle
```ruby
make: string (1-50 chars, required)
model: string (1-50 chars, required)
year: integer (1900 < year <= current_year + 1, required)
color: string (1-30 chars, required)
license_plate: string (unique, 1-20 chars, required)
customer_id: integer (required)

Relationships:
- belongs_to :customer
- has_many :reservations
```

### Reservation
```ruby
start_time: datetime (required, must be future)
end_time: datetime (required, must be after start_time)
status: string (pending|confirmed|cancelled|completed, required)
customer_id: integer (required)
vehicle_id: integer (required)

Relationships:
- belongs_to :customer
- belongs_to :vehicle
```

## Business Rules

Reservation constraints:
- Start time must be in the future (except completed/cancelled)
- End time must be after start time
- No overlapping reservations for same vehicle
- Cancelled reservations don't block time slots

Data integrity:
- Customer emails must be unique
- Vehicle license plates must be unique
- Year must be between 1900 and next year

Cascading deletes:
- Deleting customer removes vehicles and reservations
- Deleting vehicle removes associated reservations

## Usage Examples

### Complete Workflow

```bash
# 1. Create a customer
curl -X POST http://localhost:3000/api/v1/customers \
  -H "Content-Type: application/json" \
  -d '{"customer": {"name": "Jane Smith", "email": "jane@example.com", "phone": "555-1234"}}'

# 2. Create a vehicle for the customer
curl -X POST http://localhost:3000/api/v1/vehicles \
  -H "Content-Type: application/json" \
  -d '{"vehicle": {"make": "Honda", "model": "Civic", "year": 2021, "color": "Red", "license_plate": "XYZ789", "customer_id": 1}}'

# 3. Create a reservation
curl -X POST http://localhost:3000/api/v1/reservations \
  -H "Content-Type: application/json" \
  -d '{"reservation": {"customer_id": 1, "vehicle_id": 1, "start_time": "2024-12-15T10:00:00Z", "end_time": "2024-12-15T12:00:00Z", "status": "pending"}}'

# 4. Get upcoming reservations
curl http://localhost:3000/api/v1/reservations?upcoming=true

# 5. Update reservation status
curl -X PATCH http://localhost:3000/api/v1/reservations/1 \
  -H "Content-Type: application/json" \
  -d '{"reservation": {"status": "confirmed"}}'
```

## Development

### Database Migrations

```bash
rails generate migration AddFieldToTable
rails db:migrate
rails db:rollback
```

### Rails Console

```bash
rails console
# or
rails c
```

### View Routes

```bash
rails routes | grep api
```

## Troubleshooting

### PostgreSQL Not Running

If PostgreSQL isn't running, start it with:

```bash
brew services start postgresql
brew services list
```

### Port Already in Use

```bash
rails server -p 3001
```

### Database Connection Error

Check `config/database.yml` and ensure PostgreSQL credentials are correct.

### Test Failures

Ensure test database is migrated:
```bash
RAILS_ENV=test rails db:migrate
```

## Project Structure

```
app/
  controllers/
    api/v1/
      customers_controller.rb
      vehicles_controller.rb
      reservations_controller.rb
  models/
    customer.rb
    vehicle.rb
    reservation.rb
test/
  models/
    customer_test.rb
    vehicle_test.rb
    reservation_test.rb
  controllers/
    api/v1/
      customers_controller_test.rb
      vehicles_controller_test.rb
      reservations_controller_test.rb
config/
  routes.rb
  environments/
    development.rb
    test.rb
```

## Key Technologies

- Rails 8.1
- PostgreSQL
- Bullet for N+1 query detection
- Rubocop for code style enforcement
- Minitest for testing

## Response Format

### Success Response
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "123-456-7890",
  "created_at": "2024-11-26T20:00:00.000Z",
  "updated_at": "2024-11-26T20:00:00.000Z"
}
```

### Error Response
```json
{
  "errors": [
    "Email has already been taken",
    "Phone can't be blank"
  ]
}
```

### Not Found Response
```json
{
  "error": "Customer not found"
}
```

