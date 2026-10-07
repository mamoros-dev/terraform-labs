output "hello_url" {
  description = "URL completa para probar la API: curl $(terraform output -raw hello_url)"
  value       = "${aws_apigatewayv2_api.hello.api_endpoint}/hello"
}

output "api_endpoint" {
  description = "URL base de la HTTP API (sin la ruta /hello)."
  value       = aws_apigatewayv2_api.hello.api_endpoint
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda."
  value       = aws_lambda_function.hello.function_name
}

output "lambda_function_arn" {
  description = "ARN de la función. Terraform lo conoce porque él crea el resource."
  value       = aws_lambda_function.hello.arn
}

output "log_group_name" {
  description = "Log Group donde aparecen las invocaciones. Consultable en CloudWatch."
  value       = aws_cloudwatch_log_group.hello.name
}
