output "availability_zones" {
  description = "The availability zones used in this setup"
  value       = ["${var.aws_region}a", "${var.aws_region}b"]
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.dvs_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.dvs_pub_sub1.id, aws_subnet.dvs_pub_sub2.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.dvs_priv_sub1.id, aws_subnet.dvs_priv_sub2.id]
}

output "web_server_tags" {
  description = "The tags for the web servers"
  value       = {
    server_1 = aws_instance.dvs_web_svr1.tags.Name
    server_2 = aws_instance.dvs_web_svr2.tags.Name
  }
}

output "app_server_tags" {
  description = "The tags for the app servers"
  value       = {
    server_1 = aws_instance.dvs_app_svr1.tags.Name
    server_2 = aws_instance.dvs_app_svr2.tags.Name
  }
}

output "web_server_public_ips" {
  description = "The public IP addresses of the web servers"
  value       = {
    server_1 = aws_instance.dvs_web_svr1.public_ip
    server_2 = aws_instance.dvs_web_svr2.public_ip
  }
}

output "app_server_private_ips" {
  description = "The private IP addresses of the app servers"
  value       = {
    server_1 = aws_instance.dvs_app_svr1.private_ip
    server_2 = aws_instance.dvs_app_svr2.private_ip
  }
}