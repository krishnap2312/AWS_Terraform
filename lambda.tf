resource "aws_lambda_function" "modify_sg" {
  filename      = "/workspaces/AWS_Terraform/lambda_function/lambda_function.zip"
  function_name = "ModifySGFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      SECURITY_GROUP_ID = aws_security_group.TF_SG.id
    }
  }
}

