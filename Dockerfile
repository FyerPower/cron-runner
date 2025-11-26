FROM alpine:3.18

# Install cron and bash
RUN apk add --no-cache bash dcron

# Create scripts directory
RUN mkdir -p /scripts

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /scripts

# Run entrypoint
ENTRYPOINT ["/entrypoint.sh"]
