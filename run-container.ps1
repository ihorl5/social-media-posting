# PowerShell script to run Docker container with environment variables

# Method 1: Using docker-compose (recommended)
Write-Host "Starting container with docker-compose..." -ForegroundColor Green
docker-compose up -d

# Method 2: Using docker run with env file
# First, create .env file from example
if (!(Test-Path ".env")) {
    Write-Host "Creating .env file from env.example..." -ForegroundColor Yellow
    Copy-Item "env.example" ".env"
}

# Run with docker run (alternative method)
Write-Host "Alternative: Running with docker run..." -ForegroundColor Green
docker run -d `
    --name n8n-social-media `
    --env-file .env `
    -p 5678:3000 `
    -v n8n_data:/home/node/.n8n `
    -v ${PWD}/data:/data `
    n8n-social-media:latest

Write-Host "Container started successfully!" -ForegroundColor Green
Write-Host "Access N8N at: http://localhost:5678" -ForegroundColor Cyan
