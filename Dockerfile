FROM n8nio/n8n:latest

USER root
# FFmpeg + Python + pip + yt-dlp + AWS CLI
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    ca-certificates \
    curl \
    git \
    yt-dlp \
    && pip3 install --no-cache-dir awscli

# Optional: place your watermark
# COPY watermark.png /data/watermark.png

USER node
ENV N8N_PORT=3000
EXPOSE 3000
