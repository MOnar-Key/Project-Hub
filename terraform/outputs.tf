output "s3_bucket_name" {
    description = "S3 bucket name for website files"
    value = aws_s3_bucket.site_bucket.bucket
}
output "cloudfront_domain_name" {
    description = "CloudFront domain "
    value = aws_cloudfront_distribution.cdn.domain_name
}
output "cloudfront_distribution_id" {
    description = "Cloudfront distribtion ID"
    value = aws_cloudfront_distribution.cdn.id
}