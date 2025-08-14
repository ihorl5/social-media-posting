FROM n8nio/n8n:latest

USER root

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

# FFmpeg + Python + pip + yt-dlp + AWS CLI
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    ca-certificates \
    curl \
    git \
    yt-dlp \
    aws-cli

# Optional: place your watermark
# COPY watermark.png /data/watermark.png



RUN aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID && \
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY && \
    aws configure set default.region $AWS_DEFAULT_REGION

USER node
ENV N8N_PORT=3000
EXPOSE 3000
