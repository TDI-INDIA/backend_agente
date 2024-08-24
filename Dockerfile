FROM python:3.11

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy source code
COPY . /app/

# Update and install system dependencies
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y libnss3 libnspr4 libdbus-1-3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 libjpeg-dev libwayland-client0 libwayland-egl1 libwayland-server0 xdg-utils xvfb

# Update pip
RUN pip install --upgrade pip==24.0

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY pyproject.toml /app/
RUN pip install -r pyproject.toml

# Install Playwright dependencies and browsers
RUN npx playwright install-deps && npx playwright install

# Command to run the application
CMD ["uvicorn", "ae.server.api_routes:app", "--host", "0.0.0.0", "--port", "8000"]
