# 출력 값들
output "compartment_id" {
  description = "Created compartment OCID"
  value       = oci_identity_compartment.free_tier_compartment.id
}

output "vcn_id" {
  description = "VCN OCID"
  value       = oci_core_vcn.free_tier_vcn.id
}

output "subnet_id" {
  description = "Public subnet OCID"
  value       = oci_core_subnet.public_subnet.id
}

output "a1_instance_info" {
  description = "A1 instance details"
  value = {
    id         = oci_core_instance.a1_instance.id
    public_ip  = oci_core_instance.a1_instance.public_ip
    private_ip = oci_core_instance.a1_instance.private_ip
    shape      = oci_core_instance.a1_instance.shape
    state      = oci_core_instance.a1_instance.state
  }
}

output "micro_instance_1_info" {
  description = "Micro instance 1 details"
  value = {
    id         = oci_core_instance.micro_instance_1.id
    public_ip  = oci_core_instance.micro_instance_1.public_ip
    private_ip = oci_core_instance.micro_instance_1.private_ip
    shape      = oci_core_instance.micro_instance_1.shape
    state      = oci_core_instance.micro_instance_1.state
  }
}

output "micro_instance_2_info" {
  description = "Micro instance 2 details"
  value = {
    id         = oci_core_instance.micro_instance_2.id
    public_ip  = oci_core_instance.micro_instance_2.public_ip
    private_ip = oci_core_instance.micro_instance_2.private_ip
    shape      = oci_core_instance.micro_instance_2.shape
    state      = oci_core_instance.micro_instance_2.state
  }
}

output "ssh_connection_commands" {
  description = "SSH connection commands for all instances"
  value = {
    a1_instance     = "ssh -i ~/.ssh/codelab.pem ubuntu@${oci_core_instance.a1_instance.public_ip}"
    micro_instance_1 = "ssh -i ~/.ssh/codelab.pem ubuntu@${oci_core_instance.micro_instance_1.public_ip}"
    micro_instance_2 = "ssh -i ~/.ssh/codelab.pem ubuntu@${oci_core_instance.micro_instance_2.public_ip}"
  }
}

output "web_urls" {
  description = "Web URLs for nginx servers"
  value = {
    a1_instance     = "http://${oci_core_instance.a1_instance.public_ip}"
    micro_instance_1 = "http://${oci_core_instance.micro_instance_1.public_ip}"
    micro_instance_2 = "http://${oci_core_instance.micro_instance_2.public_ip}"
  }
}

output "resource_summary" {
  description = "Summary of created resources"
  value = {
    total_instances = 3
    a1_flex = {
      count = 1
      ocpus = 4
      memory_gb = 24
    }
    micro_instances = {
      count = 2
      ocpus_each = 1
      memory_gb_each = 1
    }
    networking = {
      vcn_cidr = "10.0.0.0/16"
      subnet_cidr = "10.0.0.0/24"
      internet_gateway = true
    }
  }
}