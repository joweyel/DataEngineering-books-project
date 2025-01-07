resource "aws_s3_bucket" "book-recommendation-data-bucket" {
  bucket = var.s3-bucket-name
  tags = {
    Name = "${var.s3-bucket-name}"
  }
}