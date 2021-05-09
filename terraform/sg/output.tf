output "main" {
  value = aws_security_group.main
}

output "alb" {
  value = aws_security_group.alb
}

output "ecs" {
  value = aws_security_group.ecs
}

output "mongo" {
  value = aws_security_group.mongo
}
