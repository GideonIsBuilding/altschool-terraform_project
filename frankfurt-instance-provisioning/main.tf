module "franfurt-instance" {
  source     = "/c/Users/User/OneDrive/Documents/AltSchool Third Semester/modules/EU-servers"
  app_region = "eu-central-1"
  ami        = "ami-06dd92ecc74fdfb36"
}

module "vpc" {
  source = "../modules/aws-instance"

  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}
