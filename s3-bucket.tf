#1 -this will create a S3 bucket in AWS
resource "aws_s3_bucket" "terraform_state_s3" {
  bucket = "terraform-vic-s3-bucket" 
}



# 2 - this Creates Dynamo Table
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tf-up-and-run-locks-vic"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}


#Step 3 - Creates S3 backend
terraform {
  backend "s3" {
    bucket         = "terraform-vic-s3-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-up-and-run-locks-vic"
    encrypt        = true
    }
}