# AWS CLI in Docker Container Setup

This guide shows you how to configure and use AWS CLI within your Docker container with a one-command setup.

## 🚀 Quick Start

### For Windows Users (PowerShell)

```powershell
# 1. Setup AWS configuration
.\setup-aws.ps1 setup

# 2. Edit .env file with your AWS credentials
notepad .env

# 3. Start the container
docker-compose up -d

# 4. Validate credentials
.\setup-aws.ps1 validate

# 5. Test AWS CLI
.\setup-aws.ps1 aws s3 ls
```

### For Linux/Mac Users (Bash)

```bash
# 1. Make script executable
chmod +x setup-aws.sh

# 2. Setup AWS configuration
./setup-aws.sh setup

# 3. Edit .env file with your AWS credentials
nano .env

# 4. Start the container
docker-compose up -d

# 5. Validate credentials
./setup-aws.sh validate

# 6. Test AWS CLI
./setup-aws.sh aws s3 ls
```

## 📋 Configuration

### 1. Environment Variables

The AWS credentials are configured through environment variables in `docker-compose.yml`:

```yaml
environment:
  - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  - AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
  - AWS_DEFAULT_OUTPUT=${AWS_DEFAULT_OUTPUT:-json}
```

### 2. .env File

Create a `.env` file with your AWS credentials:

```env
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=us-east-1
AWS_DEFAULT_OUTPUT=json
```

## 🔧 Available Commands

### Setup Script Commands

| Command     | Description                               |
| ----------- | ----------------------------------------- |
| `setup`     | Create .env file from template            |
| `validate`  | Validate AWS credentials                  |
| `test`      | Test AWS CLI installation and credentials |
| `aws <cmd>` | Run AWS CLI command in container          |

### Examples

```bash
# List S3 buckets
./setup-aws.sh aws s3 ls

# List EC2 instances
./setup-aws.sh aws ec2 describe-instances

# Get caller identity
./setup-aws.sh aws sts get-caller-identity

# Upload file to S3
./setup-aws.sh aws s3 cp local-file.txt s3://my-bucket/

# Download file from S3
./setup-aws.sh aws s3 cp s3://my-bucket/file.txt ./
```

## 🔒 Security Best Practices

### 1. IAM Roles and Permissions

- Use IAM users with minimal required permissions
- Consider using IAM roles for EC2 instances
- Regularly rotate access keys

### 2. Environment Variables

- Never commit `.env` files to version control
- Use different credentials for different environments
- Consider using AWS Secrets Manager for production

### 3. Docker Security

- The container runs as non-root user (`node`)
- Credentials are only available inside the container
- No persistent storage of credentials

## 🐛 Troubleshooting

### Common Issues

1. **Credentials not found**

   ```bash
   # Check if .env file exists and has correct format
   cat .env
   ```

2. **Container not running**

   ```bash
   # Start the container
   docker-compose up -d

   # Check container status
   docker-compose ps
   ```

3. **AWS CLI not working**

   ```bash
   # Test AWS CLI installation
   ./setup-aws.sh test

   # Check AWS CLI version
   docker-compose exec n8n aws --version
   ```

4. **Permission denied**
   ```bash
   # Make script executable (Linux/Mac)
   chmod +x setup-aws.sh
   ```

### Debug Commands

```bash
# Check container logs
docker-compose logs n8n

# Enter container shell
docker-compose exec n8n sh

# Check environment variables in container
docker-compose exec n8n env | grep AWS

# Test AWS configuration
docker-compose exec n8n aws configure list
```

## 📚 Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## 🔄 Alternative Configuration Methods

### Option 1: AWS Credentials File

You can also mount AWS credentials file:

```yaml
volumes:
  - ~/.aws:/home/node/.aws:ro
```

### Option 2: IAM Roles (EC2/EKS)

If running on AWS infrastructure, use IAM roles:

```yaml
environment:
  - AWS_PROFILE=default
```

### Option 3: AWS SSO

For AWS SSO users:

```bash
# Configure AWS SSO
docker-compose exec n8n aws configure sso
```

## 📝 Notes

- AWS CLI is pre-installed in the Docker image
- The container uses Alpine Linux for smaller size
- All AWS CLI commands run in the context of the `node` user
- Environment variables are automatically available to AWS CLI
