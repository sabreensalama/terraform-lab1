# Configure the AWS Provider
provider "aws" {
    region       = "us-west-2"
    shared_credentials_file = "~/.aws/credentiels"
    profile      = "test"
}
