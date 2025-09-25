# Use a random suffix to ensure resource names are globally unique
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# --- S3 Buckets ---

resource "aws_s3_bucket" "source" {
  bucket = "${var.project_name}-source-${random_string.suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "source_block" {
  bucket = aws_s3_bucket.source.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "destination" {
  bucket = "${var.project_name}-dest-${random_string.suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "destination_block" {
  bucket = aws_s3_bucket.destination.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- IAM Role and Policy for Lambda (Least Privilege) ---

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role-${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.source.arn}/*"]
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.destination.arn}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name   = "lambda-s3-permissions"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

# --- Lambda Function ---

resource "aws_lambda_function" "image_processor" {
  function_name = "${var.project_name}-processor-${random_string.suffix.result}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 90
  memory_size   = 512
  filename         = "../dist/image_processor.zip"
  source_code_hash = filebase64sha256("../dist/image_processor.zip")

  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.destination.bucket
      THUMBNAIL_SIZE     = "150,150"
      WEB_SIZE           = "800,600"
    }
  }
}

# --- S3 Trigger for Lambda ---

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}