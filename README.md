# byzantium_cloud_and_automation_package
-- Overview --
The Cloud Setup & Automation Package is an end-to-end AWS modernization solution designed to replace manual file handling, strengthen security, automate routine workflows, and establish a scalable cloud foundation for small or growing businesses.
This project demonstrates real-world AWS architecture design using Terraform, serverless compute, identity governance, and monitoring systems—all deployed as reproducible Infrastructure as Code (IaC).

The solution implements:
= Secure and organized cloud storage
= Automated file-processing workflows
= Least-privilege identity management with MFA enforcement
= Network isolation and private routing
= Operational monitoring, logging, and auditability
This repository serves as both a deployable package and a portfolio-grade demonstration of applied cloud engineering.

-- Architecture Summary --
The environment is built entirely on AWS services and includes:

Storage & Data Organization
= Amazon S3 for structured file management
= incoming/ prefix for uploads
= processed/ prefix for automated workflows
= Versioning enabled for safety
= Lifecycle rules for cost optimization
= Server access logs delivered to a dedicated logs bucket

Serverless Automation
= AWS Lambda function triggered by S3 events
= Automatically processes or moves new files
= Runs inside private subnets for enhanced security
= Emits detailed execution logs to CloudWatch

Identity & Access Controls
AWS IAM configured with:
= Execution role for Lambda with least-privilege permissions
= Example business user restricted to specific S3 prefixes
= Mandatory MFA for sensitive operations

Networking
Amazon VPC with:
= Public and private subnets across two Availability Zones
= NAT gateway for secure outbound access
= DNS and routing configurations for scalability

Monitoring & Governance
= Amazon CloudWatch
= Log groups for Lambda
= Alarms detecting runtime errors
= AWS CloudTrail

Multi-region event logging for auditability

Log delivery into the central logs bucket
