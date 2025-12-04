//Create logs bucket
resource "aws_s3_bucket" "logs" {
    bucket = "${local.project_name}-logs"
    tags = merge(local.common_tags, {
        Purpose = "central-logs"
    })
}
//Public access settings = blocked
resource "aws_s3_bucket_public_access_block" "logs" {
    bucket = aws_s3_bucket.logs.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true 
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
    bucket = aws_s3_bucket.logs.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

//Create data bucket
resource "aws_s3_bucket" "data" {
    bucket = "${local.project_name}-data"
    tags = merge(local.common_tags, {
        Purpose = "business-data"
    })
}

//Public access settings = blocked
resource "aws_s3_bucket_public_access_block" "data" {
    bucket = aws_s3_bucket.data.id
    block_public_acls = true 
    block_public_policy = true 
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data" {
    bucket = aws_s3_bucket.data.id
    versioning_configuration {
        status = "Enabled"
    }
}

// Bucket logging activated and set to be sent to logs bucket
resource "aws_s3_bucket_logging" "data" {
    bucket = aws_s3_bucket.data.id
    
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = "s3-access-logs/" 
}

//Lifecycle configuration specific to business use case
resource "aws_s3_bucket_lifecycle_configuration" "data" {
    bucket = aws_s3_bucket.data.id

    rule {
        id = "transition-and-expire"
        status = "Enabled"

        filter {
            prefix = ""
        }
        transition {
            days = 30
            storage_class = "STANDARD_IA"
        }
        expiration {
            days = 365
        }
    }
}