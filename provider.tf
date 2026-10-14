terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Local backend: state persists on the self-hosted agent between pipeline runs.
  # To upgrade to Azure Blob Storage, replace this block with:
  #   backend "azurerm" {}
  # and pass -backend-config flags in the pipeline (see azure-pipelines.yml comments).
  backend "local" {}
}

provider "azurerm" {
  features {}

  # Credentials are injected by the pipeline via environment variables:
  #   ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_OIDC_TOKEN
  # Set use_oidc = true for Workload Identity Federation (recommended).
  # If using a client secret instead, remove use_oidc and the pipeline sets ARM_CLIENT_SECRET.
  use_oidc = true
}
