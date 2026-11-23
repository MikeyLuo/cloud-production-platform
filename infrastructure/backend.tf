terraform {
  backend "s3" {
    bucket       = "cloud-production-platform-tfstate-718539180984"
    key          = "portfolio/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}