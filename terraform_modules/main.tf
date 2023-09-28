module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.3"
  network_name = "shote-vpc-network"
  project_id   = var.project_id

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = var.cdir
      subnet_region = var.region

    },
  ]
  secondary_ranges = {
    subnet-01 = []

  }
}

module "fabric-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "7.3.0"
  project_id              = var.project_id
  network                 = module.network.network_name
  internal_ranges_enabled = true
  internal_ranges         = var.range_firewall

}