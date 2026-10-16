# 🚀 Lab 12: AWS Databases Masterclass & Infrastructure as Code

Welcome to the **AWS Databases Masterclass** repository. This suite provides a complete set of Infrastructure as Code (IaC) templates written in **Terraform** to deploy, configure, and manage diverse database architectures on **Amazon Web Services (AWS)**. 

Designed for hands-on production engineering and preparation for the **AWS Certified Solutions Architect – Associate (SAA-C03)** exam, this project covers everything from relational multi-region deployments to high-performance distributed engines and serverless NoSQL datastores.

---

## 🗂️ Lab Modules & Navigation

This repository is structured into four specialized sub-modules, each demonstrating key AWS database patterns:

| Directory | Core Service | Database Engine | Key Features Covered |
| :--- | :--- | :--- | :--- |
| **[01.RDS_POSTGRESQL](./01.RDS_POSTGRESQL/README.md)** | Amazon RDS | PostgreSQL | Multi-AZ High Availability, Private Subnets, Bastion Host Access, KMS Encryption. |
| **[02.RDS_MYSQL](./02.RDS_MYSQL/README.md)** | Amazon RDS | MySQL | Read Replicas (Asynchronous), Read-Scaling Architecture, Automated Backups. |
| **[03.AURORA](./03.AURORA/README.md)** | Amazon Aurora | Aurora (PostgreSQL / MySQL) | Distributed Storage Engine, Shared Storage Volume, Auto-healing, Fast Failover (<30s). |
| **[04.DYNAMODB](./04.DYNAMODB/README.md)** | Amazon DynamoDB | NoSQL (KeyValue/Doc) | Fully Serverless, On-Demand Capacity (PAY_PER_REQUEST), IAM-based Security, Single-digit ms latency. |

---

## 📐 Overall Architecture Pattern

All relational database modules operate within a secure, multi-tier **Amazon VPC** infrastructure:

```text
 💻 Developer Workstation
        │
        ├──> (Git / GitHub Workflow)
        │
        └──> [Terraform CLI] ──(IaC Apply)──> 🌐 AWS Cloud (VPC)
                                                   │
                                                   ├── 🔓 Public Subnet (AZ1)
                                                   │      └─ [🛡️ EC2 Bastion Host]
                                                   │              │ (SSH Tunnel / Port 3306 or 5432)
                                                   │              v
                                                   ├── 🔒 Private Subnets (AZ1 & AZ2)
                                                   │      ├─ [🐘 RDS PostgreSQL / MySQL (Multi-AZ)]
                                                   │      └─ [⚡ Aurora Cluster Nodal Shared Storage]
                                                   │
                                                   └── ⚡ Amazon DynamoDB (Serverless / IAM Auth)
```

### Key Security & Architectural Highlights:
1. **Network Isolation:** All databases reside in **Private Subnets** without public IP addresses.
2. **Access Control:** Connection is strictly controlled via **Security Groups** allowing inbound traffic on database ports (3306 for MySQL/Aurora, 5432 for PostgreSQL) exclusively from the **Bastion Host** (jump box).
3. **High Availability:** Multi-AZ deployments with automatic failover and cross-AZ read replicas.
4. **IAM-native Auth:** DynamoDB utilizes AWS IAM credentials and fine-grained policies instead of traditional username/password combinations.

---

## 🛠️ Prerequisites & Local Setup

To run any module within this repository, ensure you have the following installed and configured:

- **Terraform** (`>= 1.5.0`)
- **AWS CLI** (`>= 2.x`)
- **AWS Account** with appropriate permissions for VPC, EC2, RDS, Secrets Manager, and DynamoDB.
- **SSH Key Pair** generated locally for Bastion Host access (`id_rsa` / `id_rsa.pub`).

---

## 🚀 Quick Start Deployment Guide

Navigate to any desired lab directory and execute the Terraform workflow:

### 1. Initialize Working Directory
```bash
cd 01.RDS_POSTGRESQL  # Or 02.RDS_MYSQL, 03.AURORA, 04.DYNAMODB
terraform init
```

### 2. Validate and Plan
```bash
terraform validate
terraform plan -out=tfplan
```

### 3. Deploy Infrastructure
```bash
terraform apply tfplan
```

### 4. Connect to Infrastructure
Refer to the `outputs` displayed upon deployment completion. Connect to your database using the Bastion Host as an SSH jump box:

```bash
# Example SSH Tunneling to Private RDS/Aurora Instance
ssh -i ~/.ssh/id_rsa -L 3306:<DB_ENDPOINT>:3306 ec2-user@<BASTION_PUBLIC_IP>
```

### 5. Destroy Infrastructure (Cleanup)
When testing is complete, destroy resources to avoid unnecessary cloud costs:
```bash
terraform destroy -auto-approve
```

---

## 📚 Exam Cheat Sheet (AWS SAA-C03 Quick Reference)

- **RDS Multi-AZ:** Synchronous replication to a standby instance in a different AZ for **Disaster Recovery (DR)**.
- **RDS Read Replicas:** Asynchronous replication for **Read Scaling**. Can be cross-region or promoted to a standalone database.
- **Amazon Aurora:** Storage is decoupled from compute. Replicates 6 copies of data across 3 AZs. Supports up to 15 Read Replicas.
- **DynamoDB:** Fully serverless NoSQL database providing single-digit millisecond latency. Uses Partition Keys (Hash) and Sort Keys (Range) for instant data retrieval.

---

## Author
+ Miguel — [GitHub](https://github.com/mamoros-dev) · [LinkedIn](https://www.linkedin.com/in/miguel-amoros-moret/)
