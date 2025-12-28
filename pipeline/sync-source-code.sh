set -e

# Load environment variables (`AWS_ACCOUNT_ID`, `AWS_PROFILE`, `TF_VERSION`)
source .env

# Environment
case "$1" in 
  dev)
    WORKSPACE=dev
    VAR_FILE=${2:-"env_configs/dev.tfvars"}
    ;;
  staging)
    WORKSPACE=staging
    VAR_FILE=${2:-"env_configs/staging.tfvars"}
    ;;
  prod)
    WORKSPACE=prod
    VAR_FILE=${2:-"env_configs/prod.tfvars"}
    ;;
  *)
    echo "Usage: $0 <dev|staging|prod> [var_file]"
    exit 1
    ;;
esac
echo "Using workspace: '$WORKSPACE' for Terraform deployment"

# TF version
if ! terraform version | grep -qF "$TF_VERSION"; then
  echo "Terraform version $TF_VERSION is required"
  exit 1
fi

# Build source files
echo "Building source code"
rm -rf ./dist
pnpm i
pnpm build

# Get the Package Version (used for the )
APP_NAME=$(cat package.json | jq -r '.name')
APP_VERSION=$(cat package.json | jq -r '.version')
echo "$APP_NAME -> $APP_VERSION"


AWS_S3_BUCKET_NAME="$APP_NAME-$WORKSPACE"

AWS_PROFILE="$AWS_PROFILE" aws s3 rm s3://$AWS_S3_BUCKET_NAME --recursive
AWS_PROFILE="$AWS_PROFILE" aws s3 sync dist/ s3://$AWS_S3_BUCKET_NAME/ --exclude "*.DS_Store*"
AWS_PROFILE="$AWS_PROFILE" aws s3 cp dist/index.html s3://$AWS_S3_BUCKET_NAME/ --cache-control max-age=0
