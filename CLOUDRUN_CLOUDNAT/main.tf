provider "google" {
  project = "ageless-span-399117"
  region  = "us-east1"
}


#criando uma vpc a parte para rodar o cloud run\
resource "google_compute_network" "vpc-cloudrun" {
  name = "shote-vpc"

}

#criando a subrede
resource "google_compute_subnetwork" "subrede-cloudrun" {
  name          = "subrede-cloudrun"
  ip_cidr_range = "172.16.205.0/28"
  network       = google_compute_network.vpc-cloudrun.id
  region        = "us-east1"

}

#criando o connector vpc para o cloud run
resource "google_project_service" "vpc" {
  service = "vpcaccess.googleapis.com"

}

resource "google_vpc_access_connector" "connector-default" {
  name   = "connector-cloudrun"
  region = "us-east1"

  subnet {
    name = google_compute_subnetwork.subrede-cloudrun.name
  }

  depends_on = [google_project_service.vpc]

}

#configurando o cloudNAT

resource "google_compute_router" "ip-router" {
  name    = "static-ip-router"
  network = google_compute_network.vpc-cloudrun.name
  region  = google_compute_subnetwork.subrede-cloudrun.region

}

#criando um ip publico resovervado
resource "google_compute_address" "static-ip" {
  name   = "static-ip-cloudrun"
  region = google_compute_subnetwork.subrede-cloudrun.region

}

resource "google_compute_router_nat" "nat-route-default" {
  name   = "static-nat"
  router = google_compute_router.ip-router.name
  region = google_compute_subnetwork.subrede-cloudrun.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.static-ip.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subrede-cloudrun.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

}

#configurando o cloudrun
resource "google_cloud_run_v2_service" "cloudrun-showip" {
  name     = "show-ip"
  location = google_compute_subnetwork.subrede-cloudrun.region

  template {
    containers {
      image = "us-east1-docker.pkg.dev/ageless-span-399117/labs/show-ip:1.0"
    }
    scaling {
      max_instance_count = 5
    }
    vpc_access {
      connector = google_vpc_access_connector.connector-default.id
      egress    = "ALL_TRAFFIC"
    }
  }
  ingress = "INGRESS_TRAFFIC_ALL"

}

#Permitindo usuario nao autorizado a rodar o cloud run
resource "google_cloud_run_service_iam_binding" "unauth" {
  location = google_compute_subnetwork.subrede-cloudrun.region
  service  = google_cloud_run_v2_service.cloudrun-showip.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]

}

