//Define the values that Terraform with immediately output for me to see after Terraform apply
// No digging through a sea of info - Get what I need right away
output "vpc_id" {
    description = "ID of the created VPC"
    value = module.vpc.vpc_id
}

output "private_subnets" {
    description = "Private subnet Ids where Lambda is running"
    value = module.vpc.private_subnets
}

output "data_bucket_name" {
    description = "Main S3 data bucket for business files"
    value = aws_s3_bucket.data.bucket
}

output "logs_bucket_name" {
    description = "Central logs bucket S3 bucket for business files"
    value = aws_s3_bucket.logs.bucket
}

output "lambda_function_name" {
    description = "Name of file processing Lambda function"
    value = aws_lambda_function.file_processor.function_name
}

output "business_user_name" {
    description = "Example IAM username for the limited-permission business user"
    value = aws_iam_user.business_user.name
}