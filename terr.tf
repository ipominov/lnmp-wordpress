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
  name = "vm-bastion"
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
    subnet_id = yandex_vpc_subnet.subnet-bastion.id
    security_group_ids = [yandex_vpc_security_group.bastionsg.id]
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM NGINX 1

resource "yandex_compute_instance" "nginx-one" {
  name = "vm-nginx-1"
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
    security_group_ids = [yandex_vpc_security_group.nginxsg.id]
    nat                = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM NGINX 2

resource "yandex_compute_instance" "nginx-two" {
  name = "vm-nginx-2"
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
    security_group_ids = [yandex_vpc_security_group.nginxsg.id]
    nat                = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM ELASTICSEARCH/LOGSTASH

resource "yandex_compute_instance" "elasticsearch" {
  name = "vm-elasticsearch"
  zone = "ru-central1-a"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 6
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  boot_disk {
    initialize_params {
      image_id = "fd8t82r4n6u4rm577l9b"
      size = 20
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-elastcisearch.id
    security_group_ids = [yandex_vpc_security_group.elasticsg.id]
    nat                = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM PROMETHEUS

resource "yandex_compute_instance" "prometheus" {
  name = "vm-prometheus"
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
      size = 20
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-prometheus.id
    security_group_ids = [yandex_vpc_security_group.prometheussg.id]
    nat                = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM KIBANA

resource "yandex_compute_instance" "kibana" {
  name = "vm-kibana"
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
    subnet_id          = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.publicsg.id]
    nat                = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM GRAFANA

resource "yandex_compute_instance" "grafana" {
  name = "vm-grafana"
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
      size = 20
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.publicsg.id]
    nat                = true
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# СЕТИ И ПОДСЕТИ---------------------------------------------------------

resource "yandex_vpc_network" "network-netology" {
  name = "all-net"
}

resource "yandex_vpc_subnet" "subnet-bastion" {
  name           = "sbn-bastion"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.9.0/24"]
}

resource "yandex_vpc_subnet" "subnet-public" {
  name           = "sbn-public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-nginx-one" {
  name           = "sbn-nginx-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_vpc_subnet" "subnet-nginx-two" {
  name           = "sbn-nginx-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

resource "yandex_vpc_subnet" "subnet-elastcisearch" {
  name           = "sbn-elasticsearch"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.13.0/24"]
}

resource "yandex_vpc_subnet" "subnet-prometheus" {
  name           = "sbn-prometheus"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.14.0/24"]
}

# SECURITY GROUPS ------------------------------------------------------

resource "yandex_vpc_security_group" "bastionsg" {
  name        = "bastion-sg"
  description = "SG for bastion"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "All in"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "publicsg" {
  name        = "public-sg"
  description = "SG for bastion"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "in kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
  ingress {
    protocol       = "TCP"
    description    = "in grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "nginxsg" {
  name        = "nginx-sg"
  description = "SG for nginx"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "All HTTP in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "All HTTPS in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "node exporter in"
    v4_cidr_blocks = ["192.168.14.0/24"]
    port           = 9100
  }
  ingress {
    protocol       = "TCP"
    description    = "nginx log exporter in"
    v4_cidr_blocks = ["192.168.14.0/24"]
    port           = 4040
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elasticsg" {
  name        = "elastic-sg"
  description = "SG for elastic and logstash"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTP to Elastic"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 9200
  }
  ingress {
    protocol       = "TCP"
    description    = "to logstash from beats"
    v4_cidr_blocks = ["192.168.11.0/24", "192.168.12.0/24"]
    port           = 5044
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prometheussg" {
  name        = "prometheus-sg"
  description = "SG for prometheus"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTP in"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 9090
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
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
