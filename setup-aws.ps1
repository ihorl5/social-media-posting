# AWS CLI One-Command Setup Script for Windows
# This script helps you configure AWS credentials for your Docker container

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

Write-Host "🚀 AWS CLI Configuration Setup" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Function to validate AWS credentials
function Test-AwsCredentials {
    Write-Host "🔍 Validating AWS credentials..." -ForegroundColor Yellow
    
    # Check if .env file exists
    if (-not (Test-Path ".env")) {
        Write-Host "❌ Error: .env file not found" -ForegroundColor Red
        Write-Host "Please run: .\setup-aws.ps1 setup" -ForegroundColor Yellow
        exit 1
    }
    
    # Load environment variables from .env file
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
    
    # Check if credentials are set
    $accessKey = [Environment]::GetEnvironmentVariable("AWS_ACCESS_KEY_ID")
    $secretKey = [Environment]::GetEnvironmentVariable("AWS_SECRET_ACCESS_KEY")
    
    if (-not $accessKey -or -not $secretKey) {
        Write-Host "❌ Error: AWS credentials not found in .env file" -ForegroundColor Red
        Write-Host "Please edit .env file and add your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY" -ForegroundColor Yellow
        exit 1
    }
    
    # Test credentials using AWS CLI in container
    Write-Host "🧪 Testing AWS credentials in Docker container..." -ForegroundColor Yellow
    try {
        $result = docker-compose exec n8n aws sts get-caller-identity 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ AWS credentials are valid!" -ForegroundColor Green
            Write-Host $result
        } else {
            Write-Host "❌ AWS credentials validation failed" -ForegroundColor Red
            Write-Host "Please check your credentials in .env file" -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "❌ Error testing AWS credentials: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to run AWS CLI command
function Invoke-AwsCommand {
    if (-not $Arguments) {
        Write-Host "❌ Error: No AWS command provided" -ForegroundColor Red
        Write-Host "Usage: .\setup-aws.ps1 aws <aws-cli-command>" -ForegroundColor Yellow
        Write-Host "Example: .\setup-aws.ps1 aws s3 ls" -ForegroundColor Yellow
        exit 1
    }
    
    $cmd = $Arguments -join " "
    Write-Host "🔧 Running AWS CLI command: aws $cmd" -ForegroundColor Yellow
    docker-compose exec n8n aws $Arguments
}

# Main script logic
switch ($Command) {
    "setup" {
        Write-Host "📋 Setting up AWS configuration..." -ForegroundColor Yellow
        if (-not (Test-Path ".env")) {
            Copy-Item "env.example" ".env"
            Write-Host "✅ .env file created! Please edit it with your AWS credentials." -ForegroundColor Green
        } else {
            Write-Host "✅ .env file already exists" -ForegroundColor Green
        }
        Write-Host ""
        Write-Host "📝 Please edit .env file with your AWS credentials, then run:" -ForegroundColor Yellow
        Write-Host "   .\setup-aws.ps1 validate" -ForegroundColor Cyan
    }
    
    "validate" {
        Test-AwsCredentials
    }
    
    "aws" {
        Invoke-AwsCommand
    }
    
    "test" {
        Write-Host "🧪 Running AWS CLI test commands..." -ForegroundColor Yellow
        docker-compose exec n8n aws --version
        Write-Host ""
        docker-compose exec n8n aws sts get-caller-identity
        Write-Host ""
        docker-compose exec n8n aws configure list
    }
    
    default {
        Write-Host "🔧 AWS CLI Docker Helper Script" -ForegroundColor Green
        Write-Host "===============================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Usage: .\setup-aws.ps1 <command>" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Cyan
        Write-Host "  setup     - Create .env file from template" -ForegroundColor White
        Write-Host "  validate  - Validate AWS credentials" -ForegroundColor White
        Write-Host "  test      - Test AWS CLI installation and credentials" -ForegroundColor White
        Write-Host "  aws <cmd> - Run AWS CLI command in container" -ForegroundColor White
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Cyan
        Write-Host "  .\setup-aws.ps1 setup" -ForegroundColor White
        Write-Host "  .\setup-aws.ps1 validate" -ForegroundColor White
        Write-Host "  .\setup-aws.ps1 aws s3 ls" -ForegroundColor White
        Write-Host "  .\setup-aws.ps1 aws ec2 describe-instances" -ForegroundColor White
        Write-Host "  .\setup-aws.ps1 test" -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Quick Start:" -ForegroundColor Cyan
        Write-Host "1. .\setup-aws.ps1 setup" -ForegroundColor White
        Write-Host "2. Edit .env file with your AWS credentials" -ForegroundColor White
        Write-Host "3. .\setup-aws.ps1 validate" -ForegroundColor White
        Write-Host "4. .\setup-aws.ps1 aws s3 ls" -ForegroundColor White
    }
}
