# 이미지 데이터 소스
# Ubuntu 24.04 for ARM (A1)
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = oci_identity_compartment.free_tier_compartment.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Ubuntu 24.04 for x86 (E2.1.Micro)
data "oci_core_images" "ubuntu_x86" {
  compartment_id           = oci_identity_compartment.free_tier_compartment.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# A1 Flex 인스턴스 (ARM - 4 OCPU, 24GB RAM)
resource "oci_core_instance" "a1_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.free_tier_compartment.id
  display_name        = "a1-free-tier-instance"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "a1-primary-vnic"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx
      systemctl enable nginx
      echo "<h1>A1 Free Tier Instance</h1>" > /var/www/html/index.html
      echo "<p>Private IP: $(hostname -I | awk '{print $1}')</p>" >> /var/www/html/index.html
    EOF
    )
  }

  freeform_tags = {
    "Type" = "Free-Tier"
    "OS"   = "Ubuntu-24.04-ARM"
  }
}

# E2.1.Micro 인스턴스 1
resource "oci_core_instance" "micro_instance_1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.free_tier_compartment.id
  display_name        = "micro-instance-1"
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_x86.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "micro1-primary-vnic"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx
      systemctl enable nginx
      echo "<h1>Micro Instance 1</h1>" > /var/www/html/index.html
      echo "<p>Private IP: $(hostname -I | awk '{print $1}')</p>" >> /var/www/html/index.html
    EOF
    )
  }

  freeform_tags = {
    "Type" = "Free-Tier"
    "OS"   = "Ubuntu-24.04-x86"
  }
}

# E2.1.Micro 인스턴스 2
resource "oci_core_instance" "micro_instance_2" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.free_tier_compartment.id
  display_name        = "micro-instance-2"
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_x86.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "micro2-primary-vnic"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx
      systemctl enable nginx
      echo "<h1>Micro Instance 2</h1>" > /var/www/html/index.html
      echo "<p>Private IP: $(hostname -I | awk '{print $1}')</p>" >> /var/www/html/index.html
    EOF
    )
  }

  freeform_tags = {
    "Type" = "Free-Tier"
    "OS"   = "Ubuntu-24.04-x86"
  }
}