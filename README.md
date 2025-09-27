# OCI Free Tier Terraform 구성 (개발환경용)

⚠️ **주의: 이 구성은 개발/학습 목적으로 설계되었습니다**
- 프로덕션 환경에서는 추가적인 보안 설정 필요
- 네트워크 접근 제한, 모니터링, 백업 정책 등 고려 필요

이 Terraform 구성은 Oracle Cloud Infrastructure (OCI) 무료 티어를 최대한 활용하여 **개발환경용** 리소스를 생성합니다:

## 생성되는 리소스

### 컴퓨트 인스턴스
- **A1 Flex 인스턴스 1개**: 4 OCPU, 24GB RAM (ARM 기반, Ubuntu 24.04)
- **E2.1.Micro 인스턴스 2개**: 각각 1 OCPU, 1GB RAM (x86 기반, Ubuntu 24.04)

### 네트워킹
- **VCN**: 10.0.0.0/16 CIDR 블록
- **공용 서브넷**: 10.0.0.0/24
- **인터넷 게이트웨이**: 외부 인터넷 연결
- **라우트 테이블**: 기본 라우팅 설정
- **보안 리스트**: SSH 및 내부 통신 허용

### 추가 기능
- 모든 인스턴스에 Nginx 자동 설치
- 인스턴스 간 내부 네트워크 통신 허용
- SSH 접속 설정

## 사용 방법

### 1. 사전 준비
```bash
# Terraform 설치 확인
terraform version

# OCI CLI 설정 확인
oci --version
```

### 2. 구성 파일 설정
```bash
# terraform.tfvars 파일 생성 (민감한 정보 포함)
cp terraform.tfvars.example terraform.tfvars

# 실제 OCI 인증 정보로 수정
vim terraform.tfvars

# 필수 정보:
# - tenancy_ocid: OCI 테넌시 OCID
# - user_ocid: 사용자 OCID
# - fingerprint: API 키 지문
# - ssh_public_key: SSH 공개 키
```

### 3. Terraform 실행
```bash
# Terraform 초기화
t init

# 실행 계획 확인
t plan

# 리소스 생성
t apply
```

### 4. 리소스 확인
```bash
# 출력 값 확인
t output

# SSH 연결 명령어 확인
t output ssh_connection_commands
```

## 파일 구조

- `main.tf`: 메인 구성 (Provider, VCN, 서브넷, 보안 설정)
- `instances.tf`: 컴퓨트 인스턴스 구성
- `outputs.tf`: 출력 값 정의
- `variables.tf`: 변수 정의
- `versions.tf`: Terraform 및 Provider 버전 설정
- `terraform.tfvars.example`: 변수 설정 예시 (안전)
- `terraform.tfvars`: 실제 변수 값 (Git에서 제외됨)
- `.gitignore`: Git 추적 제외 파일 목록

## 주요 변수

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `tenancy_ocid` | OCI 테넌시 OCID | - |
| `user_ocid` | 사용자 OCID | - |
| `fingerprint` | API 키 지문 | - |
| `private_key_path` | 개인 키 파일 경로 | `~/.ssh/codelab.pem` |
| `region` | OCI 리전 | `ap-seoul-1` |
| `compartment_name` | 컴파트먼트 이름 | `free-tier-instances` |
| `ssh_public_key` | SSH 공개 키 | - |

## 무료 티어 한도

이 구성은 OCI Always Free 한도 내에서 동작합니다:

- **A1 Flex**: 4 OCPU, 24GB RAM (최대 한도)
- **E2.1.Micro**: 2개 인스턴스 (최대 한도)
- **네트워킹**: VCN, 서브넷, 보안 리스트, 인터넷 게이트웨이 (무료)
- **스토리지**: 각 인스턴스별 기본 부트 볼륨 (총 200GB까지 무료)

## 연결 테스트

### SSH 접속

**기본 방법:**
```bash
# A1 인스턴스 SSH 접속
ssh -i ~/.ssh/codelab.pem ubuntu@<A1_PUBLIC_IP>

# Micro 인스턴스 1 SSH 접속
ssh -i ~/.ssh/codelab.pem ubuntu@<MICRO1_PUBLIC_IP>

# Micro 인스턴스 2 SSH 접속
ssh -i ~/.ssh/codelab.pem ubuntu@<MICRO2_PUBLIC_IP>
```

**별칭 사용 (권장):**
```bash
# IP 주소를 Terraform output에서 확인
t output sshConnectionCommands
# 결과 예시:
# "a1_instance" = "ssh -i ~/.ssh/codelab.pem ubuntu@xxx.xxx.xxx.xxx"
# "micro_instance_1" = "ssh -i ~/.ssh/codelab.pem ubuntu@yyy.yyy.yyy.yyy"
# "micro_instance_2" = "ssh -i ~/.ssh/codelab.pem ubuntu@zzz.zzz.zzz.zzz"

# 별칭으로 간편 접속 (IP 주소가 이미 설정되어 있음)
a1  # A1 인스턴스
m1  # Micro 인스턴스 1
m2  # Micro 인스턴스 2
```

### 네트워크 및 서비스 테스트

```bash
# 웹 URL 확인
t output webUrls
# 결과 예시:
# "a1_instance" = "http://xxx.xxx.xxx.xxx"
# "micro_instance_1" = "http://yyy.yyy.yyy.yyy"
# "micro_instance_2" = "http://zzz.zzz.zzz.zzz"

# Nginx 웹 서버 확인
curl http://<A1_PUBLIC_IP>     # A1 인스턴스
curl http://<MICRO1_PUBLIC_IP> # Micro 인스턴스 1
curl http://<MICRO2_PUBLIC_IP> # Micro 인스턴스 2

# 내부 네트워크 ping 테스트 (SSH 접속 후)
ping <MICRO_INSTANCE_PRIVATE_IP>
```

## 정리

사용이 끝나면 다음 명령어로 모든 리소스를 삭제할 수 있습니다:

```bash
t destroy
```

## Remote Backend 설정

### 🤔 Remote Backend를 설정하면 뭐가 달라지나?

**설정 전 (로컬 상태):**
- `terraform.tfstate` 파일이 내 컴퓨터에만 저장됨
- 팀원과 상태 공유 불가능
- 내 컴퓨터가 고장나면 상태 파일 손실 위험
- 동시에 `terraform apply` 실행하면 충돌 가능

**설정 후 (Remote Backend):**
- `terraform.tfstate` 파일이 OCI Object Storage에 저장됨 ☁️
- 팀원들이 같은 상태 파일 공유 가능 👥
- 상태 파일 백업 및 버전 관리 자동화 🔄
- 상태 잠금으로 동시 작업 충돌 방지 🔒
- 어디서든 `terraform plan/apply` 가능 🌍

### 실제 확인해보기

**로컬 파일 확인:**
```bash
ls -la terraform.tfstate*
# 결과:
# terraform.tfstate (0 바이트 - 비어있음!)
# terraform.tfstate.backup (48KB - 마이그레이션 전 백업)
```

**원격 저장소 확인:**
```bash
oci os object list --bucket-name terraform-state-bucket
# 결과:
# terraform.tfstate (48KB - 실제 상태 데이터가 여기 저장됨)
```

**💡 핵심**: 로컬 `terraform.tfstate`는 이제 빈 파일이고, 실제 상태는 OCI Object Storage에 저장됨!

### 팀 협업 시나리오

**동료가 새로 합류한다면:**
1. Git에서 코드 clone
2. Terraform 최신 버전 설치
3. `terraform init` 실행
4. 자동으로 OCI Object Storage에서 상태 다운로드
5. 바로 `terraform plan` 가능! 🎉

**동시 작업 보호:**
- A가 `terraform apply` 실행 중
- B가 `terraform apply` 시도
- → "상태 잠금" 오류 발생으로 충돌 방지
- A 작업 완료 후 B가 작업 가능

### OCI 네이티브 Backend 설정

**필수 조건**: Terraform v1.12.0 이상

1. **Terraform 최신 버전 설치**
```bash
# 최신 버전 다운로드 및 설치 (v1.12.0 이상)
curl -LO "https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_darwin_arm64.zip"
unzip terraform_1.13.3_darwin_arm64.zip
mv terraform ~/bin/terraform_latest

# 별칭 설정으로 기본 명령어로 사용 (권장)
echo 'alias terraform="~/bin/terraform_latest"' >> ~/.zshrc
echo 'alias t="~/bin/terraform_latest"' >> ~/.zshrc

# SSH 접속 별칭 설정 (선택사항)
# 먼저 IP 주소 확인: t output sshConnectionCommands
# 아래 IP를 실제 값으로 교체하세요
echo 'alias a1="ssh -i ~/.ssh/codelab.pem ubuntu@YOUR_A1_IP"' >> ~/.zshrc
echo 'alias m1="ssh -i ~/.ssh/codelab.pem ubuntu@YOUR_MICRO1_IP"' >> ~/.zshrc
echo 'alias m2="ssh -i ~/.ssh/codelab.pem ubuntu@YOUR_MICRO2_IP"' >> ~/.zshrc

source ~/.zshrc

# 버전 확인
t -v
# 또는
terraform version
```

2. **OCI 네임스페이스 확인**
```bash
oci os ns get
# 결과: cnqphqevfxnp
```

3. **Terraform 상태 저장용 버킷 생성**
```bash
oci os bucket create \
  --compartment-id "ocid1.compartment.oc1..aaaaaaaa[your-compartment-id]" \
  --name "terraform-state-bucket" \
  --public-access-type "NoPublicAccess"
```

4. **backend.tf 설정 (OCI 네이티브)**
```hcl
terraform {
  backend "oci" {
    bucket    = "terraform-state-bucket"
    key       = "terraform.tfstate"
    namespace = "your-namespace"
    region    = "ap-seoul-1"
  }
}
```

5. **상태 마이그레이션 실행**
```bash
echo "yes" | t init -migrate-state
# 결과: Successfully configured the backend "oci"!
```

6. **성공 확인**
```bash
# 상태 파일이 OCI Object Storage에 저장되었는지 확인
oci os object list --bucket-name terraform-state-bucket

# Terraform plan 정상 작동 확인
t plan
# 결과: No changes. Your infrastructure matches the configuration.
```

### 핵심 요구사항
- **Terraform 버전**: v1.12.0 이상 필수
- **OCI CLI 설정**: 기본 인증 설정 완료
- **Object Storage 버킷**: 미리 생성 필요

## 보안 고려사항

### ⚠️ 개발환경 보안 주의사항
- **이 구성은 학습/개발 목적**: 프로덕션 사용 시 추가 보안 강화 필요
- **SSH 포트 전체 오픈**: 개발 편의성을 위해 0.0.0.0/0에서 SSH 허용
- **HTTP 포트 오픈**: Nginx 테스트를 위해 웹 포트 오픈
- **프로덕션에서는**: 특정 IP 대역으로 제한, WAF, 모니터링 등 추가 필요

### 민감한 정보 관리
- `terraform.tfvars` 파일은 Git에 커밋하지 않음 (`.gitignore`에 포함됨)
- `terraform.tfstate` 파일도 Git에서 제외됨 (민감 정보 포함)
- OCI 인증 정보는 절대 공개 저장소에 업로드하지 말 것
- SSH 키 파일은 안전한 위치에 보관 (권한: 600)
- API 키는 정기적으로 교체 권장

### 현재 네트워크 보안 (개발환경 설정)
- SSH 접속: 전체 인터넷에서 허용 (0.0.0.0/0:22)
- HTTP 접속: 전체 인터넷에서 허용 (0.0.0.0/0:80)
- VCN 내부: 모든 통신 허용 (10.0.0.0/16)
- ICMP: ping 허용

## 주의사항

### 🔧 개발환경 관련
1. **개발/학습 목적**: 이 구성은 프로덕션용이 아님
2. **보안 설정**: 편의성을 위해 일부 보안 설정이 느슨함
3. **네트워크 오픈**: SSH, HTTP 포트가 전체 인터넷에 오픈됨

### 💰 비용 및 리소스
4. **무료 티어 한도**: 기존에 다른 무료 티어 리소스가 있다면 한도 초과 가능
5. **리전 제한**: 일부 리전에서는 A1 인스턴스 사용 불가
6. **비용 모니터링**: 예상치 못한 요금 발생 방지를 위해 정기적으로 확인

### 🔐 보안 관리
7. **키 관리**: SSH 키는 안전하게 보관 (권한 600 설정)
8. **민감 정보**: terraform.tfvars 파일을 Git에 커밋하지 말 것
9. **정기 검토**: 사용하지 않는 리소스는 즉시 삭제

## 트러블슈팅

### 인스턴스 생성 실패
- A1 인스턴스: 용량 부족 시 다른 가용성 도메인 시도
- 무료 티어 한도 확인

### 네트워크 연결 문제
- 보안 리스트 규칙 확인
- 인터넷 게이트웨이 상태 확인
- 라우트 테이블 설정 확인


---

