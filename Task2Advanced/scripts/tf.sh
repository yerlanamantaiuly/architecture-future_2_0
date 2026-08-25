#!/usr/bin/env bash
# Локальный и CI-скрипт: terraform init / plan / apply
# с удалённым S3-совместимым backend. State на диск не пишется.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT}/terraform"
ACTION="${1:-plan}"          # init | plan | apply | destroy
ENV_NAME="${2:-dev}"         # dev | stage | prod

if [[ ! "${ENV_NAME}" =~ ^(dev|stage|prod)$ ]]; then
  echo "ENV must be dev|stage|prod, got: ${ENV_NAME}" >&2
  exit 1
fi

TFVARS="${TF_DIR}/envs/${ENV_NAME}.tfvars"
BUCKET="${TF_STATE_BUCKET:-future20-tfstate}"
ENDPOINT="${TF_STATE_ENDPOINT:-https://storage.yandexcloud.net}"
STATE_KEY="envs/${ENV_NAME}/terraform.tfstate"

if [[ ! -f "${TFVARS}" ]]; then
  echo "Missing ${TFVARS}" >&2
  exit 1
fi

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set (S3/MinIO credentials)." >&2
  exit 1
fi

BACKEND_FLAGS=(
  -backend-config="bucket=${BUCKET}"
  -backend-config="key=${STATE_KEY}"
  -backend-config="endpoints={s3=\"${ENDPOINT}\"}"
  -backend-config="region=ru-central1"
)

cd "${TF_DIR}"

terraform init -reconfigure -input=false "${BACKEND_FLAGS[@]}"

case "${ACTION}" in
  init)
    ;;
  plan)
    terraform plan -input=false -var-file="${TFVARS}" -out="tfplan-${ENV_NAME}"
    ;;
  apply)
    if [[ -f "tfplan-${ENV_NAME}" ]]; then
      terraform apply -input=false "tfplan-${ENV_NAME}"
    else
      terraform apply -input=false -auto-approve -var-file="${TFVARS}"
    fi
    ;;
  destroy)
    terraform destroy -input=false -auto-approve -var-file="${TFVARS}"
    ;;
  *)
    echo "Unknown action: ${ACTION}. Use init|plan|apply|destroy" >&2
    exit 1
    ;;
esac
