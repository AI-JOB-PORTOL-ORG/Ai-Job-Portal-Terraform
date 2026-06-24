terraform {
  backend "s3" {
    bucket         = "hirevoice-terraform-state-334401495505"
    key            = "hirevoice/dev/phase2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hirevoice-terraform-locks"
    encrypt        = true
  }
}
