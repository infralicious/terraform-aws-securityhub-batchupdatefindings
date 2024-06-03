terraform {
  # This is when type constraints were released
  required_version = ">= 1.1.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "> 1"
    }
  }
}
