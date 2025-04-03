# Terraform AWS Infrastructure 

This repository contains Terraform scripts to provision an AWS infrastructure setup, including a VPC, subnet, security groups, internet gateway, routing tables, two EC2 instances (master and slave), an S3 backend with state locking, and CloudWatch monitoring. The configuration is modularized for reusability and maintainability.

## Overview

The project provisions the following AWS resources:
- **VPC and Networking:**
  - A VPC with a CIDR block (default: `10.0.0.0/16`).
  - A public subnet (default: `10.0.1.0/24`).
  - An internet gateway and routing table for internet access.
  - A security group allowing SSH (port 22), HTTP (port 80), and HTTPS (port 443) inbound, port 8080 for jenkins on the master , port 9000 on the slave for SonarQube , with unrestricted outbound traffic.
- **EC2 Instances:**
  - Two Ubuntu-based EC2 instances:
    - `master`: Primary instance.
    - `slave`: Secondary instance.
- **Terraform Backend:**
  - S3 bucket for state storage with DynamoDB for state locking.
- **Monitoring:**
  - CloudWatch alarms to monitor CPU utilization on both instances.

## Directory Structure

```
├── backend.tf              # S3 backend configuration
├── main.tf                 # Root module calling sub-modules
├── modules/
│   ├── cloudwatch/         # CloudWatch monitoring module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network/            # VPC and networking module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── server/             # EC2 instance module
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── provider.tf             # AWS provider configuration
├── terraform.tfvars        # Variable values
├── variables.tf            # Variable definitions
└── outputs.tf             
```

## Prerequisites

1. **AWS Account:**
   - An active AWS account with sufficient permissions to create VPCs, EC2 instances, S3 buckets, DynamoDB tables, and CloudWatch alarms.
2. **AWS CLI:**
   - Installed and configured with credentials (`aws configure`).
3. **Terraform:**
   - Version 1.5+ installed (download from [terraform.io](https://www.terraform.io/downloads.html)).
4. **SSH Key Pair:**
   - An AWS key pair (e.g., `ivolve-key`) for SSH access to EC2 instances. Download the `.pem` file and store it securely.
5. **S3 Bucket and DynamoDB Table:**
   - An S3 bucket (e.g., `hae542-state-bucket`) for state storage.
   - A DynamoDB table (e.g., `terraform-lock-table`) with a primary key `LockID` (type: String) for state locking.

## Setup Instructions

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Configure AWS Credentials:**
   - Ensure your AWS CLI is configured with valid credentials or use an IAM role with appropriate permissions.

3. **Update Variables:**
   - Edit `terraform.tfvars` to customize values (e.g., `region`, `vpc_cidr`, etc.) if needed.
   - Example:
     ```hcl
     region      = "us-east-1"
     vpc_cidr    = "10.0.0.0/16"
     subnet_cidr = "10.0.1.0/24"
     ```

4. **Update Key Pair:**
   - In `main.tf`, set the `key_name` parameter for the `master_server` and `slave_server` modules to your AWS key pair name:
     ```hcl
     module "master_server" {
       ...
       key_name = "ivolve-key"  # Replace with your key pair name
     }
     module "slave_server" {
       ...
       key_name = "ivolve-key"  # Replace with your key pair name
     }
     ```

![image](https://github.com/user-attachments/assets/9e7f20bb-0b73-48fa-a28e-13138c420a7b)
     
5. **Create S3 bucket for Terraform State:**
   ```bash
   aws s3api create-bucket --bucket my-terraform-state-bucket --region us-east-
     ```
   Replace my-terraform-state-bucket with a unique name.
   
![image](https://github.com/user-attachments/assets/51f3ba47-21d2-4229-8511-ea907a8e8e74)

7. **Create a DynamoDB Table for State Locking:**
    ```bash
   aws dynamodb create-table --table-name terraform-lock-table \
   --attribute-definitions AttributeName=LockID,AttributeType=S \
   --key-schema AttributeName=LockID,KeyType=HASH \
   --billing-mode PAY_PER_REQUEST
     ```
![image](https://github.com/user-attachments/assets/15e1695c-8683-4545-95df-3bfda00c37f9)
      
6. **Configure Backend:**
   - Update `backend.tf` with your S3 bucket and DynamoDB table details:
     ```hcl
     terraform {
       backend "s3" {
         bucket         = "my-terraform-state-bucket"   #Repla ce with your bucket name 
         key            = "terraform/state/terraform.tfstate"
         region         = "us-east-1"
         dynamodb_table = "terraform-lock-table"
       }
     }
     ```

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   This downloads the AWS provider and initializes the S3 backend.

2. **Validate Configuration:**
   ```bash
   terraform validate
   ```

3. **Plan the Deployment:**
   ```bash
   terraform plan
   ```
   Review the planned changes to ensure they match your expectations.

4. **Apply the Configuration:**
   ```bash
   terraform apply
   ```
   Type `yes` to confirm and deploy the resources.
   
![image](https://github.com/user-attachments/assets/8675e16c-f5e1-49aa-915a-6266192903ea)

5. **View Outputs:**
   ```bash
   terraform output
   ```
   This displays the public IPs of the `master` and `slave` instances.

6. **Connect to EC2 Instances via SSH:**
   - Use the `.pem` file and public IP:
     ```bash
     ssh -i /path/to/my-ec2-key.pem ubuntu@<PUBLIC_IP>
     ```
     - Example for master: `ssh -i ~/my-ec2-key.pem ubuntu@54.123.45.67`

## Security Group Details

- **Inbound Rules:**
  - SSH (port 22, TCP): Allows remote access from anywhere (`0.0.0.0/0`).
  - HTTP (port 80, TCP): Allows unencrypted web traffic from anywhere.
  - HTTPS (port 443, TCP): Allows encrypted web traffic from anywhere.
  - port 8080 on the master for jenkins
  - port 9000 on the slave for sonarQube
- **Outbound Rules:**
  - All traffic (any port, any protocol) to anywhere (`0.0.0.0/0`).
    
## server verification 

![image](https://github.com/user-attachments/assets/a7bbc804-f5c3-4906-a84e-9d3e53b8d4b1)

![image](https://github.com/user-attachments/assets/bff502d2-76aa-47ae-90ef-b5dc37168fcb)

![image](https://github.com/user-attachments/assets/b3aa4f23-a2f4-49a9-8170-6bd28c9ece07)

## network verification 

![image](https://github.com/user-attachments/assets/ea8dfbc0-3b5a-47cc-bac4-6343dbff5722)

![image](https://github.com/user-attachments/assets/2ade13a5-4d61-4c45-bbdc-c79f8170f3be)

![image](https://github.com/user-attachments/assets/5e129957-5a61-4fba-9d67-40cf7bc9194a)

![image](https://github.com/user-attachments/assets/4fff8a30-69b7-417c-8c1a-07af4f2aa1be)

## CloudWatch verification 

<img width="960" alt="image" src="https://github.com/user-attachments/assets/3c8762cb-c2ab-444c-afc1-84db0d49e888" />

