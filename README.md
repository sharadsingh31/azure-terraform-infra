# Azure IaC Terraform & GitHub Actions Pipeline (RG, ACR, AKS)

This repository contains fully modular, production-ready Terraform configuration files to provision an **Azure Resource Group (RG)**, **Azure Container Registry (ACR)**, and **Azure Kubernetes Service (AKS)**, along with a automated CI/CD pipeline built with **GitHub Actions**.

The architecture uses a parent-child module relationship and implements `for_each` to dynamically provision resources based on configuration maps. It also automatically sets up the **AcrPull** role assignment so that the AKS cluster's Kubelet identity can pull container images from your ACR.

---

## Directory Structure

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml       # GitHub Actions workflow for Plan & Apply
├── modules/
│   ├── resource_group/         # Child module for Resource Groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── acr/                    # Child module for Container Registries
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── aks/                    # Child module for AKS Clusters
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                     # Root main module (orchestrator with for_each)
├── variables.tf                # Root input variables
├── outputs.tf                  # Root outputs mapping
├── providers.tf                # Root provider and remote backend definition
└── terraform.tfvars.example    # Example inputs template
```

---

## 1. Prerequisites & Azure Setup

Before running the GitHub Actions pipeline, you must prepare:
1. **An Azure Remote State Backend** (to store Terraform's `.tfstate` file).
2. **An Azure Service Principal** (credentials for the pipeline).

### A. Create a Remote State Storage (Azure CLI)
Run the following commands in your terminal to create the Storage Account where Terraform will store its state file:

```bash
# Define variable names
RESOURCE_GROUP_NAME="rg-terraform-state-prod"
STORAGE_ACCOUNT_NAME="tfstate$(openssl rand -hex 4)" # Must be globally unique, alphanumeric
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create a resource group for state management
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create a storage account (Standard, LRS)
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Create a blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

Keep note of your **Resource Group**, **Storage Account Name**, and **Container Name**. You will configure these in your GitHub repository.

### B. Create an Azure Service Principal
Run the following command to create an Active Directory application and service principal with **Contributor** access to your Subscription:

```bash
# Replace with your actual Azure Subscription ID
SUBSCRIPTION_ID="your-subscription-id-here"

az ad sp create-for-rbac \
  --name "github-actions-terraform" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth
```

This returns a JSON object containing credentials:
- `clientId` (Service Principal App ID)
- `clientSecret` (Service Principal Password)
- `tenantId` (Directory Tenant ID)
- `subscriptionId` (Subscription ID)

---

## 2. GitHub Actions Setup

In your GitHub repository, configure the following secrets and variables to enable the pipeline to authenticate and run.

### A. Repository Secrets
Navigate to **Settings** > **Secrets and variables** > **Actions** > **New repository secret**:

| Secret Name | Description | Value |
| :--- | :--- | :--- |
| `AZURE_CLIENT_ID` | The App/Client ID of your Azure Service Principal | `clientId` |
| `AZURE_TENANT_ID` | Your Microsoft Entra (Azure AD) Directory Tenant ID | `tenantId` |
| `AZURE_SUBSCRIPTION_ID` | Your active Azure Subscription ID | `subscriptionId` |
| `AZURE_CLIENT_SECRET` | The password/secret of your Service Principal | `clientSecret` |

*Note: For maximum security, you can also set up OpenID Connect (OIDC) trust in Azure AD. If you set up Federated Credentials for OIDC, you do not need to populate the `AZURE_CLIENT_SECRET` secret.*

### B. Repository Variables
Navigate to **Settings** > **Secrets and variables** > **Actions** > **Variables** > **New repository variable**:

| Variable Name | Description | Value |
| :--- | :--- | :--- |
| `BACKEND_RESOURCE_GROUP` | Name of the Resource Group created for TF state | `rg-terraform-state-prod` |
| `BACKEND_STORAGE_ACCOUNT` | Name of the Storage Account created for TF state | e.g. `tfstate8fae0192` |
| `BACKEND_CONTAINER` | Blob container name inside the Storage Account | `tfstate` |

---

## 3. Configuring Local / Environment Variables

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Open `terraform.tfvars` and customize your settings:
   - Make sure your container registry name is **alphanumeric** and **globally unique**.
   - Make sure the AKS DNS prefix is valid.
   - You can define multiple Resource Groups, ACRs, and AKS clusters using maps. The child modules will use `for_each` to create them dynamically!

---

## 4. How the Pipeline Works

Once you push your code (including `terraform.tfvars` or using environment variables) to GitHub:

- **Pull Requests (PR) to `main`**:
  - Automatically runs `terraform fmt -check`.
  - Automatically initializes the backend with `terraform init` using your GitHub configuration variables.
  - Automatically runs `terraform validate` to verify syntax.
  - Runs a **Dry-Run Plan** (`terraform plan`) so you can review infrastructure changes before merging.

- **Merge/Push to `main`**:
  - Performs validation checks.
  - Generates a plan (`terraform plan -out=tfplan`).
  - Automatically runs **`terraform apply`** to provision the Resource Group, ACR, and AKS cluster to Azure.

- **Manual Trigger (`workflow_dispatch`)**:
  - You can manually run the pipeline from the GitHub Actions tab.
  - Select whether to perform a `plan` or an `apply` action directly.
