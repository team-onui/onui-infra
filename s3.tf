resource "aws_s3_bucket" "default" {
  bucket = "${var.app_name}-submit"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-submit"
    name = "2-2Admin"
  }
}

resource "aws_s3_bucket_versioning" "default" {

  bucket = aws_s3_bucket.default.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "default" {

  bucket = aws_s3_bucket.default.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_policy" {

  bucket = aws_s3_bucket.default.id

  policy = data.aws_iam_policy_document.default.json
  depends_on = [aws_s3_bucket.default, aws_s3_bucket_public_access_block.default]
}

resource "aws_s3_bucket_cors_configuration" "default" {

  bucket = aws_s3_bucket.default.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT","GET"]
    allowed_origins = ["*"]//나중에 Domain 추가
    expose_headers = ["ETag"]
  }
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:Get*",
      "s3:Put*"
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.default.arn}//highthon/*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}