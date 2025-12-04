
//Adding observability and auditability with Cloudtrail and Cloudwatch

//Create Cloudwatch log group
resource "aws_cloudwatch_log_group" "lambda_logs" {
    name = "/aws/lambda/${aws_lambda_function.file_processor.function_name}"
    retention_in_days = 14
    tags = local.common_tags
}
//The actual alarm that watches Lambda "Errors" metric and sounds if there's >=1 error in 5 minutes
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
    alarm_name = "${local.project_name}-lambda-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    metric_name = "Errors"
    namespace = "AWS/Lambda"
    period = 300
    statistic = "Sum"
    threshold = 1

    dimensions = {
        FunctionName = aws_lambda_function.file_processor.function_name
    }

    alarm_description = "Alarm if Lambda function produces an errors in 5-minute period."
    treat_missing_data = "notBreaching"

    tags = local.common_tags
}

//Monitor API activity cross reagions and puts logs in log bucket
resource "aws_cloudtrail" "main" {
    name = "${local.project_name}-trail"
    s3_bucket_name = aws_s3_bucket.logs.bucket
    s3_key_prefix = "cloudtrail/"
    include_global_service_events = true
    is_multi_region_trail = true 
    enable_log_file_validation = true

    tags = local.common_tags
}

// Allow CloudTrail to write to the logs bucket
resource "aws_s3_bucket_policy" "logs_cloudtrail" {
    bucket = aws_s3_bucket.logs.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Sid = "AWSCloudTrailWrite",
                Effect = "Allow",
                Principal = {
                    Service = "cloudtrail.amazonaws.com"
                },
                Action = "s3:PutObject",
                Resource = "${aws_s3_bucket.logs.arn}/cloudtrail/*",
                Condition = {
                    StringEquals = {
                        "s3:x-amz-acl" = "bucket-owner-full-control"
                    }
                }
            },
            {
                Sid = "AWSCloudTrailAclCheck",
                Effect = "Allow",
                Principal = {
                    Service = "cloudtrail.amazonaws.com"
                },
                Action = "s3:GetBucketAcl",
                Resource = aws_s3_bucket.logs.arn
            }
        ]
    })
}
