terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "*****"
  cloud_id  = "*****"
  folder_id = "*****"
  zone      = "*****"
}

# VM BASTION

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  zone = "ru-central1-a"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  boot_disk {
    initialize_params {
      image_id = "fd8t82r4n6u4rm577l9b"
      size = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.bastion.id]
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM NGINX 1

resource "yandex_compute_instance" "nginx-one" {
  name = "nginx-1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  boot_disk {
    initialize_params {
      image_id = "fd8t82r4n6u4rm577l9b"
      size = 10
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-nginx-one.id
    security_group_ids = [yandex_vpc_security_group.http-in.id]
    nat                = false
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM NGINX 2

resource "yandex_compute_instance" "nginx-two" {
  name = "nginx-2"
  zone = "ru-central1-b"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  boot_disk {
    initialize_params {
      image_id = "fd8t82r4n6u4rm577l9b"
      size = 10
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-nginx-two.id
    security_group_ids = [yandex_vpc_security_group.http-in.id]
    nat                = false
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# СЕТИ И ПОДСЕТИ---------------------------------------------------------

resource "yandex_vpc_network" "network-netology" {
  name = "all-net"
}

resource "yandex_vpc_subnet" "subnet-public" {
  name           = "subnet-bastion"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-nginx-one" {
  name           = "subnet-nginx-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_vpc_subnet" "subnet-nginx-two" {
  name           = "subnet-nginx-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

# SECURITY GROUPS ------------------------------------------------------

resource "yandex_vpc_security_group" "http-in" {
  name        = "nginx-in"
  description = "SG for nginx"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "http in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "ssh in"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }
  egress {
    protocol       = "TCP"
    description    = "all out tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion" {
  name        = "bastion-sg"
  description = "SG for bastion"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "ssh in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  egress {
    protocol       = "TCP"
    description    = "http to nginx1 sg"
    v4_cidr_blocks = ["192.168.11.0/24", "192.168.12.0/24"]
    port        = 80
  }
  egress {
    protocol       = "TCP"
    description    = "ssh to nginx2 sg"
    v4_cidr_blocks = ["192.168.11.0/24", "192.168.12.0/24"]
    port        = 22
  }
}

# БАЛАНСИРОВЩИКИ

resource "yandex_lb_target_group" "netology-target" {

  name      = "nginx-balancer"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-nginx-one.id}"
    address   = "${yandex_compute_instance.nginx-one.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-nginx-two.id}"
    address   = "${yandex_compute_instance.nginx-two.network_interface.0.ip_address}"
  }
}

resource "yandex_lb_network_load_balancer" "netology" {
  name = "nginxbalance"

  listener {
    name = "nginx-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.netology-target.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
