resource "aws_s3_bucket" "data" {
  bucket = "${var.app_name}-${var.env}-data"
  force_destroy = true
}