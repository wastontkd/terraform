provider "google" {
  project = "ageless-span-399117"
  region  = var.regiao
}

module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.3"
  network_name = "shote-vpc-network"
  project_id   = var.project_id

  subnets = [
    {
      subnet_name   = "dev-subnet1"
      subnet_ip     = var.cdir
      subnet_region = var.regiao

    }
  ]
}

module "fabric-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "7.3.0"
  project_id              = var.project_id
  network                 = module.network.network_name
  internal_ranges_enabled = true
  internal_ranges         = var.range_firewall
  internal_target_tags    = ["internal"]
  custom_rules = {
    allow-web-access = {
      description          = "Criando resgras de firewall usando o module ao invés de resource"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = var.allow_all
      sources              = ["web"]
      targets              = ["web"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = ["8080", "80"]
        }
      ]
      extra_attributes = {}

    }
  }

}

resource "google_compute_instance" "terraform-gce" {
  name         = "terraform-gce"
  machine_type = "f1-micro"
  zone         = var.zone-us-east1

  tags = ["web", "ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        env = "dev"
      }
    }
  }

  network_interface {
    network    = module.network.network_name
    subnetwork = "dev-subnet1"


    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = file("httpd.sh")
}