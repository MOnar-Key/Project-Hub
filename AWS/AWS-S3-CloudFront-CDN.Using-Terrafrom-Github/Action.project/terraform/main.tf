resource "aws_s3_bucket" "site_bucket" {
    bucket = var.bucket_name
    tags = {
        Name = var.project_name
        Project = var.project.name
    }
}
resource "aws_s3_bucket_public_access_block" "site_bucket" {
    bucket = aws_s3_bucket.site_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id
  rule  {
    apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
    }
  }
}
resource "aws_cloudfront_origin_access_control" "oac" {
  name = "${var.project_name}-oac"
  description = "OAC for private S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}
resource "aws_cloudfront_distribution" "cdn" {
    enabled = true
    comment = "cloudfront CDN for S3 static website"
    default_root_object = "index.html"
    origin {
        domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
        origin_id = "s3-${aws_s3_bucket.site_bucket-id}"
        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }
  default_cache_behavior {
    target_origin_id = "s3-${aws-s3_bucket.site_bucket.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    compress = true
    forwarded_value {
        query_string = false 
        cookies {
            forward = "none"
        }
    }
  }
  price_class = "PriceClass_200"
  restrications {
    geo_restrication {
        restrications_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = {
    Name = var.project_name
    Project = var.project_name
  }
}
data "aws_iam_policy_document" "bucket_policy"{
    statement {
        sid = "AllowCloudFrontReadOnly"
        principle {
            type = "Service"
            indentifiers = ["cloudfront.amazonaws.com"]
        }
        action = [ 
            "s3:GetObject"
        ]
        resource = [
            "${aws_s3_bucket.site_bucket.arn}/*"
        ]
        condition {
            test = "StringEquals"
            variable = "AWS:SourceArn"
            values = [aws_cloudfront_distribution.cdn.arn]
        }
    }
}
resource "aws_s3_bucket_policy" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}