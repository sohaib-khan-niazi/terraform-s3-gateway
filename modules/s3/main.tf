resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.name}"
  force_destroy = true
  tags = merge(var.tags, { Name = "${var.name}-bucket"})    
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true   
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule { object_ownership = "BucketOwnerEnforced"}  
}
