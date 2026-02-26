# Dockerfile for SYNAPSE Hub (Brain)
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies for audio processing and build
RUN apt-get update && apt-get install -y \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
# Using a requirements approach or direct install
RUN pip install --no-cache-dir \
    faster-whisper \
    websockets \
    pyserial \
    ollama \
    python-dotenv

# Copy source code
COPY . .

# Expose WebSocket port
EXPOSE 8765

# Start command (assuming main.py is the entrypoint)
CMD ["python", "main.py"]
