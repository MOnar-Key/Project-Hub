variable "aws_region" {
  description = "AWS region Where all resources will be created"
  type = string
  default = "ap-south-1" 
}
variable "project-name" {
  description = "S3-Static-Website-Hosting-CloudFront-CDN"
  type = string
  default = "Static-Website"
}   
variable "bucket-name" {
  description = "AWSfileUploadS3toCloudFrontEdgeWebsite"
  type = string
}