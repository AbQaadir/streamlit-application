FROM python:3.9-slim

WORKDIR /app

# Install system dependencies required for Python packages and git
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the Streamlit example app from GitHub
RUN git clone https://github.com/streamlit/streamlit-example.git .

# Install Python dependencies from the cloned repo's requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Create non-root user for Choreo (UID 10016)
RUN groupadd -g 10016 choreo && \
    useradd --uid 10016 --gid 10016 --no-create-home --shell /bin/bash choreouser

# Switch to non-root user
USER 10016

# Expose port 8501 for Choreo
EXPOSE 8501

# Update healthcheck to use port 8501
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Run Streamlit on port 8501
ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]