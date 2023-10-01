output "vpc_id" {
  description = "vpc_id"
  value       = aws_vpc.main.id
}

output "private_subnets_ids" {
  description = "private subnets"
  value       = [for private_subnet in aws_subnet.private : private_subnet.id]
}
