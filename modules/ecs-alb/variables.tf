
variable "app_name" {
  default = "jfc-ecommerce"
}

variable "imageecs" {
  default = ""
}
variable "vpc_id"{}
variable "subnet_public"{}

variable "min_capacity" {
  description = "Número mínimo de tareas ECS"
  default     = 2
}

variable "max_capacity" {
  description = "Número máximo de tareas ECS"
  default     = 10
}

variable "cpu_scale_threshold" {
  description = "Umbral de CPU para escalar (ej: 70 para 70%)"
  default     = 70
}

variable "security_group_alb"{}
variable "subnet_private"{}
variable "security_group_ecs"{}

variable "region" {
  description = "AWS infrastructure region"
  type        = string
  default     = null
}