terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

variable "cluster_name" { type = string }
variable "node_role_arn" { type = string }
variable "private_subnet_ids" { type = set(string) }
variable "instance_type_by_os" {
  type = map(string)
  validation {
    condition     = contains(keys(var.instance_type_by_os), "linux") && contains(keys(var.instance_type_by_os), "windows")
    error_message = "Provide an approved instance type for both linux and windows."
  }
}

resource "aws_eks_node_group" "this" {
  for_each        = toset(["linux", "windows"])
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  ami_type        = each.key == "linux" ? "AL2023_x86_64_STANDARD" : "WINDOWS_CORE_2022_x86_64"
  instance_types  = [var.instance_type_by_os[each.key]]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    os-family = each.key
  }

  tags = {
    Name = "${var.cluster_name}-${each.key}"
  }
}

output "node_group_names" {
  value       = { for os, group in aws_eks_node_group.this : os => group.node_group_name }
  description = "Managed node group names by operating system."
}
