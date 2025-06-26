output "aws_vpc_id" {
  value       = one(aws_vpc.aws_vpc_company[*].id)
  description = "id vpc"
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas creadas"
  value       = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  description = "IDs de las subredes publicas creadas"
  value       = aws_subnet.public_subnets[*].id
}

output "aws_security_group_alb"{
  value = aws_security_group.alb.id
}

output "aws_security_group_ecs" {
  value = aws_security_group.ecs.id
}

output "aws_elasticache_subnet_group_redis" {
  value = aws_elasticache_subnet_group.redis.name  
}