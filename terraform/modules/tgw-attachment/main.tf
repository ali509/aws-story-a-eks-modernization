terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
      configuration_aliases = [aws.spoke, aws.network]
    }
  }
}

variable "tgw_id" {
  type        = string
  description = "Transit Gateway ID owned by the network account."
}

variable "vpc_id" {
  type        = string
  description = "Spoke VPC ID."
}

variable "transit_subnet_ids" {
  type        = set(string)
  description = "One dedicated TGW subnet per selected AZ."
}

variable "spoke_route_table_id" {
  type        = string
  description = "TGW route table ID selected by the network account."
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  provider           = aws.spoke
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.transit_subnet_ids

  tags = {
    Name = "story-a-dev-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  provider                      = aws.network
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.spoke_route_table_id
}

output "attachment_id" {
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
  description = "Attachment ID for explicit route and propagation controls."
}
