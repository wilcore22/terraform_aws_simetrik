# ALB para ECS
resource "aws_lb" "backend" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_alb]
  subnets            = var.subnet_public
}



# Target Group para ECS
resource "aws_lb_target_group" "backend" {
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/health"
  }
}

# Listener ALB
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}


##### Autoescalado ECS #####



resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = "ecs"  # Namespace para ECS
  resource_id        = "service/${aws_ecs_cluster.backend.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"  # Dimensión escalable
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}


resource "aws_appautoscaling_policy" "scale_up_cpu" {
  name               = "${var.app_name}-scale-up-cpu"
  service_namespace  = "ecs"  # ¡Obligatorio y debe coincidir con aws_appautoscaling_target!
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_scale_threshold
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
  }
}


# ECS Cluster
resource "aws_ecs_cluster" "backend" {
  name = "${var.app_name}-cluster"
    setting {
    name  = "containerInsights"
    value = "enabled"  
  }
}

# Task Definition para Fargate
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn  # Necesario para Fargate

  container_definitions = jsonencode([{  # <-- ¡Este es el formato correcto!
    name      = "backend",
    image     = var.imageecs,
    essential = true,
    portMappings = [{
      containerPort = 80,
      hostPort      = 80,
      protocol      = "tcp"
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name,
        "awslogs-region"        = var.region,
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "backend" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_private
    security_groups  = [var.security_group_ecs]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 80
  }
}

# Alarma
resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.app_name}-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  threshold           = 70
  statistic           = "Average"
  dimensions = {
    ClusterName = aws_ecs_cluster.backend.name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 30
}


#### Permisos ##

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_sns_topic" "alarms" {
  name = "${var.app_name}-alarms-topic"
}


resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = "sistemas@pragma.com" 
}