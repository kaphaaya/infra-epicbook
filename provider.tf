terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # -------------------------------------------------------------------------
  # BACKEND CONFIGURATION
  #
  # Current: local backend — state lives on whichever machine runs Terraform.
  # The local path is supplied via -backend-config at init time so that
  # both local runs and the pipeline use the SAME path on the agent.
  #
  # RECOMMENDED NEXT STEP — Azure Blob Storage remote backend:
  # This gives consistent state for local work and the pipeline.
  # To migrate, follow the steps in the README / SETUP.md:
  #
  #   1. Create a storage account (once, manually):
  #        az group create -n epicbook-tfstate-rg -l eastus
  #        az storage account create \
  #          -n epicbooktfstate -g epicbook-tfstate-rg \
  #          -l eastus --sku Standard_LRS \
  #          --min-tls-version TLS1_2 --allow-blob-public-access false
  #        az storage container create \
  #          --name tfstate \
  #          --account-name epicbooktfstate
  #
  #   2. Replace the backend block below with:
  #        backend "azurerm" {}
  #
  #   3. Re-run init with migration:
  #        terraform init -migrate-state \
  #          -backend-config="resource_group_name=epicbook-tfstate-rg" \
  #          -backend-config="storage_account_name=epicbooktfstate" \
  #          -backend-config="container_name=tfstate" \
  #          -backend-config="key=epicbook.tfstate"
  #
  #   4. Update azure-pipelines.yml: replace the -backend-config="path=..."
  #      lines in terraform init with the four -backend-config lines above.
  #      Pass storage_account_name as a pipeline secret variable.
  # -------------------------------------------------------------------------
  backend "local" {}
}

provider "azurerm" {
  features {
    resource_group {
      # Allow Terraform to delete a resource group that still contains resources
      # not tracked in state (orphaned from prior incomplete runs).
      prevent_deletion_if_contains_resources = false
    }
  }

  # Credentials are injected by the pipeline via environment variables:
  #   ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_OIDC_TOKEN
  # Set use_oidc = true for Workload Identity Federation (recommended).
  # If using a client secret instead, remove use_oidc and the pipeline sets ARM_CLIENT_SECRET.
  use_oidc = true
}
