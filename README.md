# AWS Serverless Demo

Serverless cloud application built using Terraform, AWS Lambda, API Gateway, and S3 static website hosting.

This project demonstrates multiple cloud deployment models and infrastructure-as-code principles while 
exploring when different AWS services are appropriate for different application requirements.

---

# Architecture

S3 Static Frontend → API Gateway → AWS Lambda

The frontend is hosted as a static website in S3 and communicates with a Python-based 
AWS Lambda function through API Gateway.

                ┌─────────────────────┐
                │     User Browser    │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │   S3 Static Website │
                │     index.html      │
                └──────────┬──────────┘
                           │ fetch()
                           ▼
                ┌─────────────────────┐
                │    API Gateway      │
                │  HTTP API Endpoint  │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │    AWS Lambda       │
                │ Python Function API │
                └─────────────────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ CloudWatch Logs     │
                └─────────────────────┘

---

# Technologies Used

- Terraform
- AWS Lambda
- API Gateway
- Amazon S3
- Python 3.11
- JavaScript
- HTML

---

# Features

- Serverless Python backend
- Static website hosting with S3
- Public HTTP API using API Gateway
- Infrastructure managed with Terraform
- Frontend-to-backend communication using fetch()
- CORS configuration for browser API access

---

# Why Different Deployment Models Matter

This project was built to understand how different AWS services solve different problems.

## EC2
Best for:
- full server control
- long-running applications
- custom environments

Tradeoffs:
- manual server management
- scaling complexity
- patching and maintenance responsibilities

## Lambda
Best for:
- lightweight APIs
- event-driven workloads
- serverless architectures

Benefits:
- automatic scaling
- lower operational overhead
- pay-per-request pricing

## S3 Static Hosting
Best for:
- static websites
- SPAs
- frontend hosting

Benefits:
- low cost
- high availability
- minimal infrastructure management

---

# Infrastructure Components

## AWS Lambda
Runs Python application code without managing servers.

## API Gateway
Provides public HTTP endpoints and routes requests to Lambda.

## S3
Hosts the frontend static website.

## Terraform
Provisions and manages all infrastructure resources.

---

# Project Structure

aws-serverless-demo/
│
├── lambda_function.py
├── lambda_function.zip
├── main.tf
├── index.html
└── README.md

---

# Deployment

## Initialize Terraform

```bash
terraform init
```

## Deploy Infrastructure

```bash
terraform apply
```

## Package Lambda Changes

After updating lambda_function.py:

```bash
zip lambda_function.zip lambda_function.py
terraform apply
```

---

# Lessons Learned

- Infrastructure as Code with Terraform
- AWS IAM permissions and roles
- API Gateway integrations
- Lambda deployment packaging
- CORS configuration
- Static website hosting with S3
- Cloud architecture tradeoffs
- Debugging distributed cloud systems

---

# Future Improvements

- Azure Functions deployment
- Multi-cloud infrastructure
- CI/CD pipeline integration
- Custom domain configuration
- Authentication and authorization
- Docker-based packaging

---

# Author

Built as a cloud/serverless infrastructure learning project.