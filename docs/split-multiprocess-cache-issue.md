# Split Dashboard Cache Issue Reproduction Guide

## Problem Overview

In a multi-process (multi-instance) server environment, after setting an experiment winner in the Split Dashboard, reloading the page may cause the display to revert to its pre-fixed state, showing inconsistent winner settings.

This occurs because the Split gem maintains cache in process memory. Each process holds an independent cache, leading to inconsistent states across different worker processes.

## Prerequisites

- Redis server must be running
- Rails application must be properly configured

## Reproduction Steps

### 1. Start Redis Server

Start Redis server in a separate terminal:

```bash
redis-server
```

Verify connection:
```bash
redis-cli ping
# Should return "PONG"
```

### 2. Start Puma with Multiple Workers

Launch Puma in cluster mode by setting the `WEB_CONCURRENCY` environment variable:

```bash
# Start with 3 workers (recommended)
WEB_CONCURRENCY=3 rails server

# Or explicitly start Puma
WEB_CONCURRENCY=3 bundle exec puma -C config/puma.rb
```

Verify in startup logs:
```
Puma starting in cluster mode...
* Version 6.x.x (ruby 3.x.x-pxxx)
* Min threads: 3, max threads: 3
* Workers: 3
* Master PID: xxxxx
```

### 3. Access Split Dashboard

Open your browser and navigate to:

```
http://localhost:3000/split
```

Authentication credentials:
- Username: `admin`
- Password: `secret`

### 4. Set Experiment Winner

1. Select an experiment from the dashboard (e.g., `todo_list_layout`)
2. In the "Winner" section, choose a specific variation (e.g., `card_view`)
3. Click "Update" or "Set Winner" button to save

### 5. Observe the Issue

**Reload the page multiple times** in your browser (F5 or Cmd+R).

#### Expected Behavior
- After setting a winner, the selected variation should consistently display as the "Winner"

#### Actual Problematic Behavior
- Display changes with each reload:
  - Some reloads show `card_view` as the winner
  - Other reloads show no winner set (reverted to pre-fixed state)
  - Different variations may appear as winner on different reloads

### 6. Debug Endpoint Verification (Optional)

Check individual worker states using the debug endpoint:

```bash
# Execute multiple times to see responses from different processes
curl http://localhost:3000/debug/split_cache_info | jq
curl http://localhost:3000/debug/split_cache_info | jq
curl http://localhost:3000/debug/split_cache_info | jq
```

Example response:
```json
{
  "process_id": 12345,
  "worker_id": "0",
  "split_cache_status": {
    "redis_connected": true,
    "experiments_count": 3,
    "cached_experiments": ["todo_list_layout", "button_color", "priority_labels"]
  },
  "experiments": [
    {
      "name": "todo_list_layout",
      "winner": "card_view"
    }
  ],
  "timestamp": "2026-02-11T10:00:00Z"
}
```

You should observe different `process_id` values returning different cache states.

## Root Cause

1. **In-Process Caching**: Split gem caches experiment configurations in each process's memory
2. **Asynchronous Cache Updates**: When winner settings are saved to Redis, each worker process's cache is not immediately updated
3. **Load Balancing**: Each HTTP request may be handled by a different worker process, causing access to different cache states on each reload

## Conditions for Occurrence

- Running in Puma cluster mode (`workers > 1`)
- Using other multi-process application servers (Unicorn, etc.)
- Deployed to production with multiple instances

## Impact

- Inconsistent Split Dashboard display
- Delayed propagation of experiment configuration changes
- Inconsistent A/B test experience for users (different winners applied by different processes)
- Inaccurate statistics

## Related Files

- `config/puma.rb`: Puma configuration (workers setting)
- `config/initializers/split.rb`: Split gem initialization
- `app/controllers/debug_controller.rb`: Debug endpoint (if exists)

## Troubleshooting

### Only One Worker Starting

Check environment variable:
```bash
echo $WEB_CONCURRENCY
```

Explicitly set:
```bash
export WEB_CONCURRENCY=3
rails server
```

### Cannot Reproduce the Issue

1. Verify multiple workers are running in Puma logs
2. Clear browser cache (separate from server cache)
3. Try with more workers (5+)
4. Use `curl` commands to manually send multiple requests

## Potential Solutions

1. **Reduce Cache TTL**: Shorten cache expiration time (temporary workaround)
2. **Direct Redis Reads**: Have Dashboard read directly from Redis (fundamental solution)
3. **Cache Invalidation Mechanism**: Implement system to invalidate all process caches on configuration changes
4. **Inter-Process Communication**: Use Pub/Sub pattern to notify cache updates
5. **Single Worker Mode**: Run in single worker mode for development (workaround)

## Additional Resources

- [Split gem documentation](https://github.com/splitrb/split)
- [Puma clustering documentation](https://github.com/puma/puma#clustered-mode)
- `SPLIT_MULTIPROCESS_TEST.md` in project root: Additional verification procedures
