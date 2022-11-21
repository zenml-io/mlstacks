# creste s3 bucket for storing artifacts
resource "aws_s3_bucket" "store" {
  bucket        = "${local.prefix}-${local.s3.name}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.store.id
  acl    = "private"
}

# block public access to the bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.store.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_object" "requirements" {
  bucket = aws_s3_bucket.store.id
  key    = "requirements.txt"
  source = "requirements.txt"

  etag = filemd5("requirements.txt")
}

resource "aws_s3_object" "dags_folder" {
  bucket       = aws_s3_bucket.store.id
  key          =  "${local.s3.dags_folder}/"
  content_type = "application/x-directory"
}

