# cron-runner

A lightweight Docker container for executing scheduled cron tasks. Designed to run as a sidecar container alongside other services in docker-compose.

## Features

- Lightweight Alpine Linux base image
- Simple cron task scheduling
- Easy integration as a sidecar container
- Support for custom scripts and schedules
- Proper permission handling for cron files

## Usage

### Quick Start

1. **Create your cron configuration file** in `cron.d/` directory:

```
# cron.d/tasks
0 2 * * * root /scripts/backup.sh >> /var/log/cron.log 2>&1
0 */6 * * * root /scripts/restart.sh >> /var/log/cron.log 2>&1
```

2. **Create your scripts** in `scripts/` directory:

```bash
# scripts/backup.sh
#!/bin/bash
echo "$(date): Running backup..."
# Your backup logic here
```

3. **Add to your docker-compose.yml**:

```yaml
services:
  cron-runner:
    image: fyerpower/cron-runner:latest
    volumes:
      - ./cron.d:/etc/cron.d:ro
      - ./scripts:/scripts:ro
    restart: unless-stopped
```

### Building from Source

```bash
docker build -t cron-runner .
```

### Running with Docker Compose

The repository includes a complete example in `docker-compose.yml`. To use it:

```bash
docker-compose up -d
```

### Volume Mounts

- **`/etc/cron.d`** - Mount your cron configuration files here (read-only recommended)
- **`/scripts`** - Mount your executable scripts here (read-only recommended)

### Cron File Format

Cron files should follow standard crontab format:

```
# minute hour day month weekday user command
0 2 * * * root /scripts/backup.sh >> /var/log/cron.log 2>&1
*/5 * * * * root /scripts/health-check.sh >> /var/log/cron.log 2>&1
```

**Note**: All times are in UTC.

## Examples

See the `examples/` directory for:
- Sample cron.d configuration (`examples/cron.d/tasks`)
- Sample scripts (`examples/scripts/`)

### Example: Database Backup Sidecar

```yaml
services:
  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret

  cron-runner:
    build: .
    volumes:
      - ./cron.d:/etc/cron.d:ro
      - ./scripts:/scripts:ro
      - db-backups:/backups
    depends_on:
      - database

volumes:
  db-backups:
```

### Example: Docker Container Restart

To restart containers from cron, mount the Docker socket:

```yaml
services:
  cron-runner:
    build: .
    volumes:
      - ./cron.d:/etc/cron.d:ro
      - ./scripts:/scripts:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

**Warning**: Mounting the Docker socket gives the container access to the Docker daemon. Use with caution.

## Permissions

The entrypoint script automatically:
- Sets execute permissions on all `.sh` files in `/scripts`
- Sets proper permissions (644) on cron.d files
- Ensures cron can read and execute tasks

## Logs

View cron logs:

```bash
docker logs cron-runner
```

For task-specific logs, redirect output in your cron configuration:

```
0 2 * * * root /scripts/backup.sh >> /var/log/cron.log 2>&1
```

Then access logs:

```bash
docker exec cron-runner cat /var/log/cron.log
```

## Troubleshooting

### Cron jobs not running

1. Check cron file permissions (should be 644)
2. Verify scripts have execute permissions
3. Ensure paths are absolute in cron files
4. Check container logs: `docker logs cron-runner`

### Script errors

Run scripts manually to debug:

```bash
docker exec cron-runner /scripts/your-script.sh
```

## License

MIT
