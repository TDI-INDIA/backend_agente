FROM python:3.11

# Set environment variables
ENV NIXPACKS_PATH /opt/venv/bin:$NIXPACKS_PATH

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

# Install Python dependencies
RUN pip install uv
RUN uv venv --python 3.11 
CMD ["source", ".venv/bin/activate"]
# RUN source .venv/bin/activate
RUN uv pip compile pyproject.toml -o requirements.txt
RUN uv pip install -r requirements.txt
RUN uv pip install -r pyproject.toml --extra dev
CMD ["playwright", "install"]
# RUN playwright install
# Install Playwright dependencies and browsers
# RUN npx playwright install-deps && npx playwright install

# Command to run the application
CMD ["cd", "ae"]
CMD ["cd", "server"]
CMD ["fastapi run", "ae/server/api_routes.py"]
