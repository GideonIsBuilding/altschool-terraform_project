module "ireland-instance" {
  source     = "../modules/EU-servers"
  app_region = "eu-west-1"
  ami = {
    "Dev"     = "ami-0694d931cee176e7d"
    "Staging" = "ami-0694d931cee176e7d"
    "Prod"    = "ami-0694d931cee176e7d"
  }

  cidr_block = "100.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["100.0.1.0/24", "100.0.2.0/24", "100.0.3.0/24"]
  public_subnets  = ["100.0.101.0/24", "100.0.102.0/24", "100.0.103.0/24"]
}
