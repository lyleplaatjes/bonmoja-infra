# Bonmoja Infrastructure

Infrastructure-as-Code for the Bonmoja staging environment.  
This repo provisions AWS infrastructure, builds/deploys Dockerized services, and configures monitoring and alerting.

---

## 📐 Architecture

- **VPC** with public/private subnets  
- **ALB** in public subnet → routes traffic to ECS Fargate tasks  
- **ECS Fargate** service running containerized HTTP app  
- **ECR** for Docker image storage  
- **RDS Postgres** database (private subnet)  
- **DynamoDB** for key/value and metadata storage  
- **SQS/SNS** for asynchronous messaging and notifications  
- **CloudWatch Logs & Alarms** for monitoring  

### Diagram

Open the provided [bonmoja-architecture.drawio](bonmoja-architecture.drawio) file in [draw.io](https://app.diagrams.net/) for editing, or use the PNG export if available.

---

## 🚀 Setup Instructions

### 1. Prerequisites
- Terraform **≥ 1.5**
- AWS account with credentials (Admin for initial bootstrap)
- GitHub repo secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION` (`eu-west-1`)
  - `DB_PASSWORD` (for RDS Postgres; blank will generate random password)
  - `NOTIFICATION_EMAIL` (SNS alerts)

### 2. Bootstrap Terraform Backend
This creates the S3 bucket and DynamoDB table used for remote state and locking.

```bash
cd infra/envs/staging
./bootstrap_backend.sh
terraform init -reconfigure
```

### 3. Apply Infrastructure
Run Terraform from inside the **staging env** folder:

```bash
cd infra/envs/staging
terraform validate
terraform plan
terraform apply
```

Terraform provisions:
- VPC, Subnets, and Security Groups
- ALB, ECS Cluster + Service, Task Definitions
- RDS, DynamoDB, SQS, SNS
- IAM roles for execution and tasks
- CloudWatch Log Groups and Alarms

### 4. CI/CD Workflows
Located in `.github/workflows/`:
- **build.yml** → Builds Docker image, tags with commit SHA, pushes to ECR
- **deploy.yml** → Runs `terraform plan/apply` with the new image, updates ECS

Workflows run automatically on pushes to `main`.

### 5. Health Check
After a deploy, run:

```bash
./scripts/health_check.sh http://<alb-dns>
```

This script sends a request to the ALB DNS and verifies HTTP 2xx/3xx response.

### 6. Cleaning Up
Destroy all resources to avoid AWS costs:

```bash
cd infra/envs/staging
terraform destroy
```

---

## 🔒 Security Notes
- IAM roles separated for ECS execution and task permissions (least privilege).
- RDS only accessible from ECS in private subnet; no public exposure.
- Secrets provided via GitHub Actions; recommend migrating to **OIDC** for production.

---

## 📊 Monitoring
- **CloudWatch Logs**: `/ecs/<service-name>` per task
- **Alarms**:
  - RDS CPU > 80% for 5 minutes
  - SQS backlog > 100 messages for 10 minutes
- Alerts sent to `NOTIFICATION_EMAIL` via SNS subscription (email confirmation required).

---

## 💰 Cost Optimization
- **Savings Plans / Reserved Instances** → Lower cost for steady usage (trade-off: long-term commitment).
- **Spot Tasks for ECS** → Huge savings for batch/stateless jobs (trade-off: interruptions).
- **RDS optimization**:
  - Use small instance types for staging (`t3.micro`)
  - Switch to **gp3** storage
  - Stop non-prod DBs outside hours
  - Consider Aurora Serverless v2 for variable workloads

---

## 📚 References
- [SOLUTION.md](SOLUTION.md) → Detailed architecture overview, trade-offs, monitoring/security rationale, cost strategies
- [scripts/health_check.sh](scripts/health_check.sh)
- [bonmoja-architecture.drawio](bonmoja-architecture.drawio) → Editable architecture diagram
