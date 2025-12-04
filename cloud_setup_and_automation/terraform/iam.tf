//Identity and access for Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "${local.project_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}
//Attach policy to Lambda service after creating policy - ability to create logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Allow Lambda ENI management when placed in a VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
//Create policy for Lambda to access S3
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${local.project_name}-lambda-s3-access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowReadWriteOnDataBucket",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*"
        ]
      }
    ]
  })
}
//Create "business user" for staff to access the system
resource "aws_iam_user" "business_user" {
    name = "${local.project_name}-business-user"
    tags = local.common_tags
}
// Give user the ability to access S3 and set parameters
// Staff can only list the incoming prefix and upload/download objects if MFA has been passed
resource "aws_iam_user_policy" "business_user_s3_policy" {
    name = "${local.project_name}-business-user-policy"
    user = aws_iam_user.business_user.name

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Sid = "AllowListBucketPrefix",
                Effect = "Allow",
                Action = [
                    "s3:ListBucket"
                ],
                Resource = aws_s3_bucket.data.arn,
                Condition = {
                    StringLike = {
                        "s3:prefix" = ["incoming/*"]
                    }
                }
            },
            {
                Sid = "AllowObjectOperationsInIncomingPrefix",
                Effect = "Allow",
                Action = [
                    "s3:GetObject",
                    "s3:PutObject"
                ],
                Resource = "${aws_s3_bucket.data.arn}/incoming/*",
                Condition = {
                    Bool = {
                        "aws:MultiFactorAuthPresent" = true
                    }
                }
            }
        ]
    })
}
