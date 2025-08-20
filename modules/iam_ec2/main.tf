# Role = identity with permissions (policies).

# Policy = rules of what the role can do (e.g., S3 read/write).

# Instance Profile = wrapper object that EC2 understands; when you launch an instance, you don’t attach the role   # directly, you attach the profile, and that profile “carries” the role into the instance.

# So: policy → attached to role → packaged into instance profile → assigned to EC2.

resource "aws_iam_role" "ec2" {
  name = "${var.name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags  
}

resource "aws_iam_policy" "s3" {
  name = "${var.name}-s3-policy"
  description = "Allow EC2 t access the bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:ListBucket","s3:GetObject","s3:PutObject"],
      Resource = [var.bucket_arn, "${var.bucket_arn}/*"]
    }]
  })
  tags = var.tags  
}

resource "aws_iam_role_policy_attachment" "attach" {
  role = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-ec2-profile"
  role = aws_iam_role.ec2.name  
}
