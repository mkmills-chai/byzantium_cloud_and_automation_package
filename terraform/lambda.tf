
// Package Lambda code from local file to avoid missing S3 object errors
data "archive_file" "file_processor_zip" {
    type        = "zip"
    source_file = "${path.module}/../lambda/handler.py"
    output_path = "${path.module}/../lambda/handler.zip"
}

//Create file_processor Lambda function
resource "aws_lambda_function" "file_processor" {
    function_name = "${local.project_name}-file-processor"

    filename         = data.archive_file.file_processor_zip.output_path
    source_code_hash = data.archive_file.file_processor_zip.output_base64sha256

    role    = aws_iam_role.lambda_exec_role.arn
    handler = "handler.lambda_handler"
    runtime = var.lambda_runtime

    memory_size = 256
    timeout     = 30

    vpc_config {
        subnet_ids         = module.vpc.private_subnets
        security_group_ids = [aws_security_group.lambda_sg.id]
    }
    environment {
        variables = {
            DATA_BUCKET_NAME = aws_s3_bucket.data.bucket
        }
    }
    tags = local.common_tags
}

resource "aws_security_group" "lambda_sg" {
    name = "${local.project_name}-lambda-sg"
    description = "Security group for Lambda in private subnets"
    vpc_id = module.vpc.vpc_id

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = local.common_tags
}
//Allows S3 to invoke the function
resource "aws_lambda_permission" "allow_s3_invoke" {
    statement_id = "AllowExecutionFromS3"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.file_processor.arn
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.data.arn
}

//Any new object under /incoming triggers Lambda
resource "aws_s3_bucket_notification" "data_bucket_notifications" {
    bucket = aws_s3_bucket.data.id
    
    lambda_function {
        lambda_function_arn = aws_lambda_function.file_processor.arn
        events = ["s3:ObjectCreated:*"] 
        filter_prefix = "incoming/"
        }
    depends_on = [aws_lambda_permission.allow_s3_invoke]
}
