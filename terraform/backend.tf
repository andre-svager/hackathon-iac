terraform {
  backend "s3" {
    bucket         = "solidarytech-terraform-state-621996700064"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
