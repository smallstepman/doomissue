FROM python:3.12-slim-bookworm

# Copy uv executables from the specified container image layer
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Update system packages and install necessary tools in one step
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    uv tool install pyright && \
    rm -rf /var/lib/apt/lists/*

# Clone the specified repository
RUN git clone https://github.com/dbrtly/dagster-workspace /app/dagster-workspace
WORKDIR /app/dagster-workspace


# Set the default command, ensuring the path is correct
CMD ["./scripts/demo_up.sh"]
