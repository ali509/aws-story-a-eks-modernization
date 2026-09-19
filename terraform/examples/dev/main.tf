terraform {
  backend "s3" {
    # Supply values with -backend-config. Never commit credentials here.
  }
}

module "spoke_attachment" {
  source              = "git::https://github.com/ali509/aws-platform-terraform-modules.git//modules/tgw-attachment?ref=v0.1.0"
  tgw_id              = var.tgw_id
  vpc_id              = var.vpc_id
  transit_subnet_ids  = var.transit_subnet_ids
  spoke_route_table_id = var.spoke_route_table_id
}

module "eks_node_groups" {
  source               = "git::https://github.com/ali509/aws-platform-terraform-modules.git//modules/eks-mixed-node-groups?ref=v0.1.0"
  cluster_name         = var.cluster_name
  node_role_arn        = var.node_role_arn
  private_subnet_ids   = var.private_subnet_ids
  instance_type_by_os  = var.instance_type_by_os
}

variable "tgw_id" { type = string }
variable "vpc_id" { type = string }
variable "transit_subnet_ids" { type = set(string) }
variable "spoke_route_table_id" { type = string }
variable "cluster_name" { type = string }
variable "node_role_arn" { type = string }
variable "private_subnet_ids" { type = set(string) }
variable "instance_type_by_os" { type = map(string) }
