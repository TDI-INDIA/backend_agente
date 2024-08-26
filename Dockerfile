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

# Install Python dependencies
RUN pip install --upgrade pip==24.0
RUN pip install virtualenv uv

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && apt-get install -y google-chrome-stable --no-install-recommends

# Set up virtual environment
RUN virtualenv .venv --python=python3.11
RUN . .venv/bin/activate && pip install fastapi uvicorn playwright && playwright install
RUN uv pip compile pyproject.toml -o requirements.txt
RUN uv pip install -r requirements.txt 
CMD ["playwright", "install chrome"]
RUN uv pip install playwright-stealth
# Expose port 8000
EXPOSE 8000

# Command to run the application
CMD [".venv/bin/uvicorn", "ae.server.api_routes:app", "--reload", "--loop", "asyncio", "--host", "0.0.0.0", "--port", "8000"]
