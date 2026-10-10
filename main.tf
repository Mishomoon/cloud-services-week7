data "openstack_networking_network_v2" "project" {
  name = var.network_name
}



resource "openstack_networking_secgroup_v2" "web" {
  name        = "${var.instance_name}-web-sg"
  description = "SSH from my IP and HTTP from anywhere - Week 7"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_port_v2" "web" {
  name               = "${var.instance_name}-port"
  network_id         = data.openstack_networking_network_v2.project.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.web.id]
}

resource "openstack_compute_keypair_v2" "week7" {
  name       = "${var.instance_name}-iac-ed25519"
  public_key = file(var.ssh_public_key_path)
}

resource "openstack_networking_floatingip_v2" "web" {
  pool        = "public"
  description = "Week 7 OpenTofu floating IP"
  port_id     = openstack_networking_port_v2.web.id
}

resource "openstack_compute_instance_v2" "week7" {
  name        = var.instance_name
  image_name  = var.image_name
  flavor_name = var.flavor_name
  key_pair = openstack_compute_keypair_v2.week7.name
  user_data = file("${path.module}/cloud-init.yaml")

  network {
    port = openstack_networking_port_v2.web.id
  }
}