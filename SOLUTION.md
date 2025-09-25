# Solution Overview

## Architecture
- AWS VPC with ALB (public), ECS Fargate (private)
- Data services: RDS Postgres, DynamoDB, SQS, SNS
- Container images stored in ECR
- CI/CD on GitHub Actions with build + deploy pipelines
- Health check script for post-deploy verification
- CloudWatch Logs + Alarms for monitoring

## Trade-offs
- **Fargate vs EC2**: chose Fargate to avoid VM ops, trade-off is less tuning for Spot.
- **RDS vs Aurora**: RDS is simpler for staging; Aurora Serverless would add elasticity but at higher complexity.
- **GitHub Actions with secrets**: currently uses repo secrets; future improvement is OIDC federation.

## Security
- IAM roles split: **exec** for ECS execution, **task** for app permissions (DDB/SQS).
- DB only in private subnets, no public access.
- Secrets not hardcoded — passed via GitHub Actions vars.

## Monitoring
- Logs in `/ecs/<name>` CloudWatch log group.
- Alarms:
  - RDS CPU > 80% for 5m
  - SQS backlog > 100 msgs for 10m
- SNS subscription for alerts (email confirmation required).

## Cost Optimization
- **Strategy 1: Savings Plans/Reserved Instances**
  - Save up to 72% on predictable workloads
  - Trade-off: must commit
- **Strategy 2: Spot Tasks for ECS**
  - Save up to 90% for stateless jobs
  - Trade-off: interruptions possible

### RDS optimization
- Right-size instance (use `t3.micro` for staging)
- Switch to **gp3** volumes (cheaper than gp2)
- Stop non-prod DBs outside hours
- Consider Aurora Serverless v2 for spiky loads

