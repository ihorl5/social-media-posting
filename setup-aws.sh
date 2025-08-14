#!/bin/bash

# AWS CLI One-Command Setup Script
# This script helps you configure AWS credentials for your Docker container

set -e

echo "🚀 AWS CLI Configuration Setup"
echo "=============================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created! Please edit it with your AWS credentials."
    echo ""
    echo "📋 Next steps:"
    echo "1. Edit .env file and add your AWS credentials"
    echo "2. Run: docker-compose up -d"
    echo "3. Test AWS CLI: docker exec n8n-social-media aws sts get-caller-identity"
    exit 0
fi

# Function to validate AWS credentials
validate_aws_credentials() {
    echo "🔍 Validating AWS credentials..."
    
    # Source the .env file
    source .env
    
    # Check if credentials are set
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "❌ Error: AWS credentials not found in .env file"
        echo "Please edit .env file and add your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    
    # Test credentials using AWS CLI in container
    echo "🧪 Testing AWS credentials in Docker container..."
    if docker-compose exec n8n aws sts get-caller-identity > /dev/null 2>&1; then
        echo "✅ AWS credentials are valid!"
        docker-compose exec n8n aws sts get-caller-identity
    else
        echo "❌ AWS credentials validation failed"
        echo "Please check your credentials in .env file"
        exit 1
    fi
}

# Function to run AWS CLI command
run_aws_command() {
    if [ -z "$1" ]; then
        echo "❌ Error: No AWS command provided"
        echo "Usage: $0 aws <aws-cli-command>"
        echo "Example: $0 aws s3 ls"
        exit 1
    fi
    
    echo "🔧 Running AWS CLI command: $*"
    docker-compose exec n8n aws "$@"
}

# Main script logic
case "$1" in
    "setup")
        echo "📋 Setting up AWS configuration..."
        if [ ! -f .env ]; then
            cp env.example .env
            echo "✅ .env file created! Please edit it with your AWS credentials."
        else
            echo "✅ .env file already exists"
        fi
        echo ""
        echo "📝 Please edit .env file with your AWS credentials, then run:"
        echo "   $0 validate"
        ;;
    "validate")
        validate_aws_credentials
        ;;
    "aws")
        shift
        run_aws_command "$@"
        ;;
    "test")
        echo "🧪 Running AWS CLI test commands..."
        docker-compose exec n8n aws --version
        echo ""
        docker-compose exec n8n aws sts get-caller-identity
        echo ""
        docker-compose exec n8n aws configure list
        ;;
    *)
        echo "🔧 AWS CLI Docker Helper Script"
        echo "==============================="
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  setup     - Create .env file from template"
        echo "  validate  - Validate AWS credentials"
        echo "  test      - Test AWS CLI installation and credentials"
        echo "  aws <cmd> - Run AWS CLI command in container"
        echo ""
        echo "Examples:"
        echo "  $0 setup"
        echo "  $0 validate"
        echo "  $0 aws s3 ls"
        echo "  $0 aws ec2 describe-instances"
        echo "  $0 test"
        echo ""
        echo "📋 Quick Start:"
        echo "1. $0 setup"
        echo "2. Edit .env file with your AWS credentials"
        echo "3. $0 validate"
        echo "4. $0 aws s3 ls"
        ;;
esac
