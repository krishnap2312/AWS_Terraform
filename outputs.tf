# Output the ID of the VPC that was created
output "aws_vpc" {
  description = "The ID of the VPC created by Terraform"
  value       = aws_vpc.tf.id
}
