module "vpc" {
  source = "./modules/vpc"

  vpc_cidr          = "10.50.0.0/16"
  private_1a_cidr   = "10.50.0.0/24"
  private_1b_cidr   = "10.50.1.0/24"
  private_1c_cidr   = "10.50.10.0/24"
  public_1a_cidr    = "10.50.2.0/24"
  public_1b_cidr    = "10.50.20.0/24"
  public_1c_cidr    = "10.50.22.0/24"
  private_zone_name = "${module.dns.private_zone_name}"
}
