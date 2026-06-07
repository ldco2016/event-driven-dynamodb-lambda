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
```

## Architectural Pillars & Core Patterns

* **Asynchronous Micro-Batching (Scalability):** Rather than tying compute resources to synchronous client requests, data is offloaded to a sequential stream layer. This protects processing units from horizontal scaling bottlenecks during traffic spikes.
* **Least-Privilege Identity Isolation (Security):** The AWS Lambda execution context is bound to a custom IAM role explicitly locked down to read stream checkpoints and write log streams, adhering strictly to the principle of zero-trust least privilege.
* **On-Demand Infrastructure (Cost Optimization):** The DynamoDB layer is provisioned in `PAY_PER_REQUEST` execution mode, coupled with zero-idle serverless Lambda functions. Operational costs scale linearly with usage-collapsing to absolute zero during idle periods.

---

## Technologies Used

* **Amazon DynamoDB:** High-performance, schema-agnostic NoSQL storage layer.
* **DynamoDB Streams:** Append-only transaction log stream emitting `NEW_IMAGE` state modification vectors.
* **AWS Lambda:** Serverless Python 3.9 compute handler executing isolated processing events.
* **Amazon CloudWatch:** Real-time logging framework providing audit controls and telemetry.
* **Terraform (IaC):** Explicit declarative blueprint mapping cloud resources and access planes.

```bash
terraform/
├── main.tf            # Core AWS Resource Orchestration & Event Source Mappings
├── terraform.tf       # Provider Locks & State Locking Configurations
└── lambda_function.py # Python-based Asynchronous Stream Event Handler
```


