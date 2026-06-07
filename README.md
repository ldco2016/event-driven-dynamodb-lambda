# Event-Driven Architecture: DynamoDB $\rightarrow$ Lambda (Terraform)

![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![DynamoDB](https://img.shields.io/badge/DynamoDB-Streams-4053D6?logo=amazon-dynamodb)
![Lambda](https://img.shields.io/badge/Lambda-Serverless-FF9900?logo=aws-lambda)
![CloudWatch](https://img.shields.io/badge/CloudWatch-Observability-FF4F8B?logo=amazon-cloudwatch)

---

## Overview
This repository implements a production-grade, asynchronous, serverless event pipeline on AWS using Terraform. It ingests transactional data via Amazon DynamoDB and dynamically triggers a decoupled AWS Lambda compute step via DynamoDB Streams.
This decoupling pattern isolates data absorption from the processing logic, ensuring high throughput, operational resilience, and zero resource starvation on downstream interfaces.

---

## Architecture Diagram
```mermaid
flowchart LR
  A[Data Ingestion / API] --> | DynamoDB PutItem | B[(Amazon DynamoDB Table)]
  B --> | Captures State Changes | C[DynamoDB Streams]
  C --> | Asynchronous Batch Trigger | D[AWS Lambda Function]
  D --> | Structured Logging | E[Amazon CloudWatch Logs]

  style B fill:#4053D6,stroke:#fff,stroke-width:2px,color:#fff
  style D fill:#FF9900,stroke:#fff,stroke-width:2px,color:#fff
