// Parameterize the configuration
// Code is reusable for different environment (i.e. dev, prod, test, client A, client B etc.)

variable "aws_region" {
    description = "AWS region being deployed into"
    type = string
    default = "us-east-1"
}

variable "project_name" {
    type = string
    default = "cloud-setup-and-automation"
}

variable "lambda_s3_bucket_key" {
    description = "Path to lambda zip inside deployment bucket"
    type = string
    default = "lambda/lambda_handler.zip"
}

variable "lambda_runtime" {
    type = string
    default = "python3.12"
}
