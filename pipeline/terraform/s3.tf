data "aws_iam_policy_document" "static_website" {
  statement {
    sid = "${var.APP_NAME}_bucket_policy_site"
    actions = ["s3:GetObject"]
    effect = "Allow"
    resources = ["arn:aws:s3:::${local.bucket_name}/*"]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  policy = data.aws_iam_policy_document.static_website.json
}


resource "aws_s3_bucket" "static_website" {
  bucket = local.bucket_name
  tags = {
    Name        = var.APP_NAME
    Environment = terraform.workspace
    Version     = var.APP_VERSION
  }
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "static_website" {
  depends_on = [aws_s3_bucket_ownership_controls.static_website]

  bucket = aws_s3_bucket.static_website.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix   = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Prevent public access to the bucket
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}