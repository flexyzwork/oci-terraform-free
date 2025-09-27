# OCI Provider 변수
variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "API key fingerprint"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
  default     = "~/.ssh/codelab.pem"
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "ap-seoul-1"
}

# 인프라 설정 변수
variable "compartment_name" {
  description = "Name of the compartment to create"
  type        = string
  default     = "free-tier-instances"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

# 네트워크 설정
variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# 인스턴스 설정
variable "a1_ocpus" {
  description = "Number of OCPUs for A1 instance"
  type        = number
  default     = 4
}

variable "a1_memory_gb" {
  description = "Memory in GB for A1 instance"
  type        = number
  default     = 24
}