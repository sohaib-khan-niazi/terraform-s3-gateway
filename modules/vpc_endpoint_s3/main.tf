data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.vpc_id
  vpc_endpoint_type = "Gateway"

  #it tells Terraform the exact AWS service (S3) in the current region to connect the VPC Endpoint to.
  service_name = "com.amazonaws.${data.aws_region.current.id}.s3"
  route_table_ids = var.route_table_ids
  
  tags = merge(var.tags, { Name = "${var.name}-s3-gw-endpoint"}) 
}

