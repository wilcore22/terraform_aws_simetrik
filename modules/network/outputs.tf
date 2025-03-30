output "aws_vpc_id" {
  value       = one(aws_vpc.aws_vpc_company[*].id)
  description = "id vpc"
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas creadas"
  value       = aws_subnet.private_subnets[*].id
}