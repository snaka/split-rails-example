# Split Dashboard Performance Testing Scripts

Performance testing scripts for Split dashboard to measure display speed when handling large amounts of A/B test data.

## Prerequisites

1. Rails application is running
2. Redis server is running
3. Ruby environment (same as Rails environment)

## Scripts Overview

### 1. performance_test.rb - Load Testing

Performs automated access to Split dashboard and application to measure performance.

**Key Features:**
- Concurrent access with configurable thread count
- Distributed access to Split dashboard, app pages, and public pages
- Generates random user sessions for each experiment
- Detailed response time statistics (average, median, 95th/99th percentile)
- Success rate measurement

**Usage:**
```bash
# Basic execution (1000 requests, 10 concurrent)
ruby scripts/performance_test.rb

# Custom settings
ruby scripts/performance_test.rb -r 5000 -c 20 -h localhost -p 3000

# Help
ruby scripts/performance_test.rb --help
```

**Options:**
- `-r, --requests COUNT`: Total number of requests (default: 1000)
- `-c, --concurrency THREADS`: Number of concurrent threads (default: 10)
- `-h, --host HOST`: Target host (default: localhost)
- `-p, --port PORT`: Target port (default: 3000)

### 2. generate_test_data.rb - Test Data Generation

Generates large amounts of A/B test data directly in Redis for Split dashboard display.

**Key Features:**
- Participant data generation for 24 experiments
- Conversion data generation for each experiment
- Customizable participant count and conversion rates
- Existing data cleanup functionality

**Usage:**
```bash
# Basic execution (10,000 participants per experiment, 10% conversion rate)
ruby scripts/generate_test_data.rb

# Custom settings
ruby scripts/generate_test_data.rb -p 50000 -r 0.15 -v

# Clear existing data before generation
ruby scripts/generate_test_data.rb --clear -p 20000

# Clear data only
ruby scripts/generate_test_data.rb --clear-only
```

**Options:**
- `-p, --participants COUNT`: Number of participants per experiment (default: 10,000)
- `-r, --conversion-ratio RATIO`: Conversion ratio 0.0-1.0 (default: 0.1)
- `--redis-url URL`: Redis URL (default: redis://localhost:6379)
- `-v, --verbose`: Verbose output
- `-c, --clear`: Clear existing data before generation
- `--clear-only`: Only clear data, don't generate new

## Performance Testing Procedure

### Step 1: Environment Setup

```bash
# Start Redis
redis-server

# Start Rails application (separate terminal)
rails server
```

### Step 2: Baseline Measurement

```bash
# Measure dashboard display speed in current state
ruby scripts/performance_test.rb -r 100 -c 5
```

### Step 3: Generate Large Dataset

```bash
# Generate large test data (50,000 participants per experiment)
ruby scripts/generate_test_data.rb -p 50000 -r 0.12 -v
```

### Step 4: Performance Test with Load

```bash
# Performance test with large dataset
ruby scripts/performance_test.rb -r 2000 -c 15
```

### Step 5: Extended Load Testing

```bash
# Re-test with even more data
ruby scripts/generate_test_data.rb -p 100000 -r 0.1 -v
ruby scripts/performance_test.rb -r 5000 -c 25
```

## Performance Evaluation Points

### Metrics to Monitor
- **Dashboard Display Time**: Loading speed of `/split` page
- **Response Time Distribution**: Average, median, 95th/99th percentile
- **Success Rate**: Error occurrence rate
- **Throughput**: Requests processed per second

### Warning Signs
- Exponential increase in display time with data growth
- Abnormal delays in 99th percentile
- Rapid increase in memory usage
- Timeout errors

## Troubleshooting

### Redis Connection Error
```bash
# Check if Redis server is running
redis-cli ping
# → Should return PONG

# Start Redis server
redis-server
```

### Rails Connection Error
```bash
# Check if Rails server is running
curl http://localhost:3000
# → Should return HTML

# Start Rails server
rails server
```

### Memory Issues
If memory shortage occurs during large data generation, reduce participant count:

```bash
# Gradually increase participant count for testing
ruby scripts/generate_test_data.rb -p 10000  # 10K
ruby scripts/generate_test_data.rb -p 25000  # 25K
ruby scripts/generate_test_data.rb -p 50000  # 50K
```

## Data Cleanup

Clean up test data as needed after testing:

```bash
# Clear only Split test data
ruby scripts/generate_test_data.rb --clear-only

# Or clear entire Redis (Warning: deletes all data)
redis-cli FLUSHALL
```

## Expected Results

Normal performance:
- Small dataset (10K participants/experiment): dashboard display < 1 second
- Medium dataset (50K participants/experiment): dashboard display < 3 seconds
- Large dataset (100K participants/experiment): dashboard display < 10 seconds

Performance issues:
- Display time increases exponentially with data volume
- 30+ seconds display time with 100K participants
- Rapid memory usage increase or OOM errors