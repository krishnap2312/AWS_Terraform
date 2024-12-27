resource "aws_s3_object" "object" {
  bucket = "practisedomain.cloud"   # Existing Bucket Name
  key    = "/securityGroups/lambda_function/"     # Update the path in s3 Bucket location 
  source = "/workspaces/AWS_Terraform/lambda_function/lambda_function.zip"       # from where you want to push the code from local

  etag = filemd5("/workspaces/AWS_Terraform/lambda_function/lambda_function.zip") # Fingerprint for secure
}