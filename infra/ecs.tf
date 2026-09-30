resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/developer-service"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "app" {
  name = "developer-service-lab"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "developer-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu                = "256"
  memory             = "512"
  execution_role_arn = var.execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name                   = "developer-service"
      image                  = var.app_image
      essential              = true
      user                   = "10001:10001"
      readonlyRootFilesystem = true

      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
        }
      }

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_VERSION"
          value = var.app_image
        }
      ]

      healthCheck = {
        command = [
          "CMD",
          "python",
          "-c",
          "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=3).close()"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "developer-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn

  launch_type   = "FARGATE"
  desired_count = 0

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }

  wait_for_steady_state = true

  timeouts {
    create = "15m"
    update = "15m"
  }

  depends_on = [
    aws_route.internet,
    aws_route_table_association.public
  ]
}