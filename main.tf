# Provider 설정
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}


# 데이터 소스
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# 컴파트먼트 생성
resource "oci_identity_compartment" "free_tier_compartment" {
  compartment_id = var.tenancy_ocid
  description    = "Free tier instances - A1 and Micro"
  name           = var.compartment_name
}

# VCN 생성
resource "oci_core_vcn" "free_tier_vcn" {
  compartment_id = oci_identity_compartment.free_tier_compartment.id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "free-tier-vcn"
}

# 인터넷 게이트웨이
resource "oci_core_internet_gateway" "free_tier_igw" {
  compartment_id = oci_identity_compartment.free_tier_compartment.id
  vcn_id         = oci_core_vcn.free_tier_vcn.id
  display_name   = "free-tier-igw"
  enabled        = true
}

# 라우트 테이블
resource "oci_core_route_table" "free_tier_route_table" {
  compartment_id = oci_identity_compartment.free_tier_compartment.id
  vcn_id         = oci_core_vcn.free_tier_vcn.id
  display_name   = "free-tier-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.free_tier_igw.id
  }
}

# 보안 리스트
resource "oci_core_security_list" "free_tier_security_list" {
  compartment_id = oci_identity_compartment.free_tier_compartment.id
  vcn_id         = oci_core_vcn.free_tier_vcn.id
  display_name   = "free-tier-security-list"

  # Egress rules - 모든 아웃바운드 트래픽 허용
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # Ingress rules - SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # VCN 내부 모든 트래픽 허용
  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/16"
    description = "Allow all traffic within VCN"
  }

  # ICMP (ping) 허용
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"

    icmp_options {
      type = 8
    }
    description = "Allow ICMP ping from anywhere"
  }

  # ICMP Type 3 (Destination Unreachable)
  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = "10.0.0.0/16"

    icmp_options {
      type = 3
    }
  }
}

# 서브넷
resource "oci_core_subnet" "public_subnet" {
  compartment_id      = oci_identity_compartment.free_tier_compartment.id
  vcn_id              = oci_core_vcn.free_tier_vcn.id
  cidr_block          = "10.0.0.0/24"
  display_name        = "public-subnet"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  route_table_id      = oci_core_route_table.free_tier_route_table.id
  security_list_ids   = [oci_core_security_list.free_tier_security_list.id]
}