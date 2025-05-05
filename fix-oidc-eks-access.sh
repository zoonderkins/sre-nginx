#!/bin/bash

# Fix OIDC EKS Access script
# This script updates the IAM roles to allow GitHub Actions to access EKS

# Set AWS profile
export AWS_PROFILE=acloud

# Make sure to specify your GitHub repository
GITHUB_REPO=${1:-"zoonderkins/sre-nginx"}

echo "GitHub repository: $GITHUB_REPO"

# Initialize Terraform
terraform init

# Apply the changes with GitHub repository variable
terraform apply -var "github_repository=$GITHUB_REPO" -auto-approve

# Get the IAM role ARN
ROLE_ARN=$(terraform output -raw github_actions_role_arn)
AWS_ACCOUNT_ID=$(echo $ROLE_ARN | cut -d ':' -f 5)

echo "========== GitHub Actions OIDC Fix Complete =========="
echo "GitHub OIDC Role ARN: $ROLE_ARN"
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo ""

# Create a temporary file for aws-auth patch
TEMP_AUTH_FILE=$(mktemp)
cat > $TEMP_AUTH_FILE << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - groups:
      - system:masters
      rolearn: ${ROLE_ARN}
      username: github-actions
EOF

echo "Creating a patch for aws-auth ConfigMap..."
echo "This will add your GitHub Actions role to the cluster's admin users"

# Check if the configmap exists first
kubectl get configmap aws-auth -n kube-system >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # Backup existing configmap
  echo "Backing up existing aws-auth ConfigMap..."
  kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-backup-$(date +%Y%m%d%H%M%S).yaml
  
  # Extract current mapRoles
  CURRENT_MAP_ROLES=$(kubectl get configmap aws-auth -n kube-system -o jsonpath='{.data.mapRoles}' 2>/dev/null)
  
  # Check if our role is already in there
  if echo "$CURRENT_MAP_ROLES" | grep -q "$ROLE_ARN"; then
    echo "Role $ROLE_ARN is already in the aws-auth ConfigMap"
  else
    # Create new mapRoles
    NEW_ROLE="    - groups:
      - system:masters
      rolearn: ${ROLE_ARN}
      username: github-actions"
    
    if [ -z "$CURRENT_MAP_ROLES" ]; then
      # No existing mapRoles
      UPDATED_MAP_ROLES="$NEW_ROLE"
    else
      # Append to existing mapRoles
      UPDATED_MAP_ROLES="${CURRENT_MAP_ROLES}
${NEW_ROLE}"
    fi
    
    # Create patch file
    PATCH_FILE=$(mktemp)
    echo "Creating patch file..."
    cat > $PATCH_FILE << EOF
data:
  mapRoles: |
${UPDATED_MAP_ROLES}
EOF
    
    echo "Patching aws-auth ConfigMap..."
    kubectl patch configmap aws-auth -n kube-system --patch "$(cat $PATCH_FILE)"
    
    rm $PATCH_FILE
  fi
else
  # Create new configmap
  echo "Creating new aws-auth ConfigMap..."
  kubectl apply -f $TEMP_AUTH_FILE
fi

rm $TEMP_AUTH_FILE

echo ""
echo "Verifying GitHub Actions role in aws-auth ConfigMap:"
kubectl get configmap aws-auth -n kube-system -o yaml | grep -A5 "${ROLE_ARN}"

echo ""
echo "To test the access with the GitHub Actions role, you can use AWS CLI assume-role-with-web-identity"
echo "(This will fail locally as it needs a token from GitHub Actions)"
echo ""
echo "Make sure your GitHub repository has the AWS_ACCOUNT_ID secret set to: $AWS_ACCOUNT_ID"

# Final output - what to do next
echo ""
echo "Next steps:"
echo "1. Add this secret to your GitHub repository: AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID"
echo "2. Verify your GitHub workflow is using the correct role ARN: $ROLE_ARN"
echo "3. Run your GitHub workflow again"

# Set execute permissions
chmod +x fix-oidc-eks-access.sh 