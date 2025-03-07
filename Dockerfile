# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com/) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.

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

# Expose port 8080 for Choreo (instead of Streamlit's default 8501)
EXPOSE 8080

# Set environment variables to influence caching behavior
ENV STREAMLIT_SERVER_ENABLE_CACHING=false
ENV STREAMLIT_SERVER_MAX_UPLOAD_SIZE=200

# Update healthcheck to use port 8080
HEALTHCHECK CMD curl --fail http://localhost:8080/_stcore/health || exit 1

# Run Streamlit with options to reduce caching and improve debugging
ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8080", "--server.address=0.0.0.0", "--server.enableCORS=false", "--server.enableXsrfProtection=false", "--server.headless=true", "--browser.gatherUsageStats=false"]