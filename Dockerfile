# Use Microsoft's official Playwright Python image (includes all browser binaries)
FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

# Set the working directory inside the container
WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright browsers matching the installed version
RUN playwright install --with-deps chromium

# Copy the rest of the application code
COPY . .

# Create the workspace directory (mount point for host files)
RUN mkdir -p /app/workspace

# Set the entrypoint
CMD ["python", "main.py"]
