// Network level isolation - private subnets for lambda
// Public subnets for internet access via NAt, etc.

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"
    
    name = "${local.project_name}-vpc"
    cidr = "10.0.0.0/16"

    // Multiple AZs for high availability
    azs = ["${var.aws_region}a", "${var.aws_region}b"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true 
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = local.common_tags
}