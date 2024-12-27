resource "aws_cloudwatch_event_rule" "trigger_lambda" {
  name                = "trigger-lambda-function"
  description         = "Trigger Lambda function at 9 AM and 5 PM"
  schedule_expression = "cron(0 9,17 * * ? *)" # 9 AM and 5 PM every day
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.trigger_lambda.name
  target_id = "lambda"
  arn       = aws_lambda_function.modify_sg.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.modify_sg.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lambda.arn
}
