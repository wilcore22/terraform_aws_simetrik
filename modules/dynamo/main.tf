resource "aws_dynamodb_table" "main" {
  name           = "${var.app_name}-db"
  billing_mode   = "PROVISIONED"  
  hash_key       = "id"
  
  
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "id"
    type = "S"  # String
  }
}


resource "aws_appautoscaling_target" "dynamodb_write" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  min_capacity       = 5
  max_capacity       = 100
}


resource "aws_appautoscaling_target" "dynamodb_read" {
  service_namespace  = "dynamodb"
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  min_capacity       = 5
  max_capacity       = 100
}


resource "aws_appautoscaling_policy" "dynamodb_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization"
  service_namespace  = aws_appautoscaling_target.dynamodb_write.service_namespace
  resource_id        = aws_appautoscaling_target.dynamodb_write.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_write.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70  
  }
}


resource "aws_appautoscaling_policy" "dynamodb_read_policy" {
  name               = "DynamoDBReadCapacityUtilization"
  service_namespace  = aws_appautoscaling_target.dynamodb_read.service_namespace
  resource_id        = aws_appautoscaling_target.dynamodb_read.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_read.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70  
  }
}