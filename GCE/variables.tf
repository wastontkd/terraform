variable "regiao" {
  default = "us-east1"
}

variable "project_id" {
  default = "ageless-span-399117"

}

variable "zone-us-east1" {
  default = "us-east1-c"
}

variable "cdir" {
  default = "172.16.205.0/24"

}

variable "range_firewall" {
  default = ["172.16.205.0/24"]

}

variable "allow_all" {
  default = ["0.0.0.0/0"]
}