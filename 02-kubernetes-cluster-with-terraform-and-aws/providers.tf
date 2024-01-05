/* São as versões que utilizaremos */

terraform {
  required_version = ">=0.13.1"
  required_providers {
    aws = ">= 3.54.0"
    local = ">= 2.1.0"
  }
}

/* É a região que vamos utilizar */
provider "aws" {
  region = "us-east-1"
}