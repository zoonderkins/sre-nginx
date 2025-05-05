# Setting Up AWS OIDC for GitHub Actions

This guide explains how to configure AWS to trust GitHub Actions for authentication using OIDC (OpenID Connect).

## Step 1: Create an IAM OIDC Identity Provider for GitHub

1. Go to the AWS IAM Console
2. Navigate to "Identity Providers" and click "Add Provider"
3. Select "OpenID Connect" as the provider type
4. For the Provider URL, enter: `https://token.actions.githubusercontent.com`
5. For the Audience, enter: `sts.amazonaws.com`
6. Click "Get thumbprint" to retrieve the certificate thumbprint
7. Click "Add provider"

## Step 2: Create an IAM Role for GitHub Actions

1. In the AWS IAM Console, navigate to "Roles" and click "Create role"
2. Under "Trusted entity type", select "Web identity"
3. For "Identity provider", select the GitHub provider you just created
4. For "Audience", select `sts.amazonaws.com`
5. Add a condition to restrict which repositories can assume this role:

```json
{
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:YOUR-GITHUB-ORG/YOUR-REPO-NAME:*"
  }
}
```

Replace `YOUR-GITHUB-ORG/YOUR-REPO-NAME` with your GitHub organization and repository name.

6. Click "Next" to configure permissions
7. Attach policies that grant the necessary permissions (at minimum):
   - `AmazonEKSClusterPolicy`
   - `AmazonEKSServicePolicy`
   - Custom policy for EKS operations (if needed)

8. Give the role a name: `github-actions-role`
9. Click "Create role"

## Step 3: Add the Required Secret to GitHub

In your GitHub repository:

1. Go to "Settings" > "Secrets and variables" > "Actions"
2. Click "New repository secret"
3. Create a secret with name `AWS_ACCOUNT_ID` and your AWS account ID as the value
   (Your AWS account ID is a 12-digit number like `123456789012`)

## Step 4: Verify Trust Relationship

Ensure the trust relationship for the IAM role includes:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-GITHUB-ORG/YOUR-REPO-NAME:*"
        }
      }
    }
  ]
}
```

## Step 5: Additional EKS Permissions

Ensure the role has permissions to manage your EKS cluster. You may need a custom policy like:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeRouteTables",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

After completing these steps, your GitHub Actions workflow should be able to authenticate with AWS using OIDC. 