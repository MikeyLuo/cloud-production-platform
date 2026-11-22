variable "aws_account_id" {
  description = "AWS account that will host the portfolio infrastructure."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "Enter your 12-digit AWS account ID."
  }
}

provider "aws" {
  region              = "ca-central-1"
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project   = "cloud-production-platform"
      ManagedBy = "Terraform"
    }
  }
}

resource "aws_dynamodb_table" "page_views" {
  name         = "cloud-production-platform-page-views"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}