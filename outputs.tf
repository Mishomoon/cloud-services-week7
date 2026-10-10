output "instance_name" {
  description = "Name of the cPouta instance"
  value       = openstack_compute_instance_v2.week7.name
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = openstack_compute_instance_v2.week7.access_ip_v4
}

output "public_ip" {
  description = "Floating public IP address of the Week 7 VM"
  value       = openstack_networking_floatingip_v2.web.address
}

output "page_url" {
  description = "Public URL of the Week 7 documentation page"
  value       = "http://${openstack_networking_floatingip_v2.web.address}/"
}