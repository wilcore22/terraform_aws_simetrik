resource "aws_elasticache_cluster" "cache" {
  cluster_id           = "${var.app_name}-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = var.elasticache_subnet_group_redis
}

resource "aws_security_group" "redis" {
  name        = "${var.app_name}-redis-sg"
  description = "Permite conexiones solo desde ECS Fargate"
  vpc_id      = var.vpc_id 

  tags = {
    Name = "${var.app_name}-redis"
  }
}

resource "aws_security_group_rule" "redis_ingress" {
  type                     = "ingress"
  from_port                = 6379 
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = var.sg_ecs 
  security_group_id        = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis.id
}