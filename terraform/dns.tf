variable "domain" {}

module "dns" {
  source = "./modules/dns"
  domain = "${var.domain}"
}
