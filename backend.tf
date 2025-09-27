# OCI Object Storage를 Terraform Backend로 사용
#
# 주의: 이 설정을 활성화하기 전에 다음을 준비해야 합니다:
# 1. OCI Object Storage 버킷 생성 완료
# 2. 적절한 권한 설정
# 3. 기존 로컬 상태 백업
#
# 활성화하려면 아래 주석을 해제하세요:

# OCI Object Storage S3 호환 API를 사용한 Remote Backend
#
# 주의: 실제 사용하려면 다음이 필요합니다:
# 1. OCI S3 호환 API 액세스 키 생성
# 2. 환경 변수 설정 (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
# 3. 기존 상태 백업
#
# 현재는 주석 처리하여 로컬 상태 사용

terraform {
  backend "oci" {
    bucket    = "terraform-state-bucket"
    key       = "terraform.tfstate"
    namespace = "cnqphqevfxnp"
    region    = "ap-seoul-1"
  }
}

# Remote Backend 사용을 위한 환경 변수 설정이 필요합니다:
# export TF_HTTP_USERNAME="your-username"
# export TF_HTTP_PASSWORD="your-auth-token"