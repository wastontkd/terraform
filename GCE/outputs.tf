output "ip_externo_instancia" {
  value = google_compute_instance.terraform-gce.network_interface.0.network_ip

}