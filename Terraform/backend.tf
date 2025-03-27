# backend.tf
terraform {
  backend "s3" {
    bucket         = "hae542-state-bucket" 
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1" 
    dynamodb_table = "terraform-lock-table" 
  }
}