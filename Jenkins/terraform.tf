terraform {
  backend "s3" {
    key = "dev/vpc"
    bucket = "ecs-fargate-docker"
    region = "us-west-2"
  }
}