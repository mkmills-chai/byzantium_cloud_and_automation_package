// Providers and general TF configuration

//Announce which versions will be required for this config
terraform {
    required_version = ">= 1.6.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    }

provider "aws" {
    region = var.aws_region
}

//Pull from variables.tf for ease
locals {
project_name = var.project_name
// Create tags that can be connected to cost allocation and organization later for ease and simplicity
common_tags = {
    Project = local.project_name
    Environment = "demo"
    ManagedBy = "Terraform"
}
}