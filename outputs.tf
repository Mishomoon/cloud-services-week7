output "instance_name" {
  description = "Name of the cPouta instance"
  value       = openstack_compute_instance_v2.week7.name
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = openstack_compute_instance_v2.week7.access_ip_v4
}