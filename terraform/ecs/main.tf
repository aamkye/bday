
resource "aws_ecs_cluster" "main" {
  name = "main_cluster"

  tags = {
    Name = "main_cluster"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "main_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  container_definitions = jsonencode([{
    name        = "main_container"
    image       = var.container_image
    essential   = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    environment = [{
      "name": "MONGODB_URL"
      "value": "mongodb://${var.dbusername}:${var.dbpassword}@${var.docdb_endpoint}:27017/?ssl=true&ssl_ca_certs=/rds-combined-ca-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
    }]
  }])

  tags = {
    Name = "main_task"
  }
}

resource "aws_ecs_service" "main" {
  name                               = "main-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.service_desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 10
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [var.sg_ecs.id]
    subnets          = var.private_subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "main_container"
    container_port   = var.container_port
  }

  tags = {
    Name = "main_service"
  }
}
