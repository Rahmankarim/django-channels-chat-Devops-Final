# ================================
# Stage 1: Builder - Build Dependencies
# ================================
FROM python:3.11-slim as builder

# Prevent Python from buffering stdout/stderr and from writing pyc files
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements to leverage Docker cache
COPY requirements /build/requirements

# Install Python dependencies and create wheels
RUN pip install --upgrade pip \
    && pip wheel --no-cache-dir --no-deps --wheel-dir /build/wheels -r requirements/live.txt

# ================================
# Stage 2: Runtime - Production Image
# ================================
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/venv/bin:$PATH" \
    DJANGO_SETTINGS_MODULE=canal.settings

WORKDIR /app

# Create non-root user for security
RUN groupadd -r django && useradd -r -g django django

# Install runtime dependencies only
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && python -m venv /venv

# Copy wheels from builder and install
COPY --from=builder /build/wheels /wheels
RUN /venv/bin/pip install --no-cache /wheels/* \
    && rm -rf /wheels

# Copy project files
COPY --chown=django:django canal/ /app/canal/
COPY --chown=django:django docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p /app/staticfiles /app/mediafiles \
    && chown -R django:django /app

# Expose port
EXPOSE 8000

# Switch to non-root user
USER django

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/chat/ || exit 1

# Set entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "canal.asgi:application"]

