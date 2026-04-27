resource "azurerm_key_vault" "main" {
  name                = "kv-qrapp-${var.environment}"  # Must be globally unique, 3-24 chars
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"  # standard vs premium (premium adds HSM)

  # Soft delete: when you delete a secret/vault, it's recoverable for this many days
  # Azure now ENFORCES a minimum of 7 days — you can't disable soft delete
  soft_delete_retention_days = 7

  # If true, you can't permanently delete the vault — good for prod, annoying for dev
  purge_protection_enabled = false

  # ── Access Policy ─────────────────────────────────────────────────────────────
  # Who can do what with secrets/keys/certificates
  # This gives YOUR identity (you running terraform) full access
  access_policy {
    tenant_id = var.tenant_id
    object_id = var.admin_object_id  # Your user's object ID from data.azurerm_client_config

    # Secret permissions: what operations are allowed on secrets
    secret_permissions = [
      "Get",     # Read a secret value
      "List",    # List secret names
      "Set",     # Create/update secrets
      "Delete",  # Delete secrets
      "Purge",   # Permanently delete (bypass soft-delete)
      "Backup",  # Create a backup
      "Restore", # Restore from backup
    ]
  }

  tags = var.tags
}

# ── Store Your App Secrets in Key Vault ───────────────────────────────────────
# These are the values from your Server/.env
# In Key Vault, secrets are versioned — changing a value creates a new version

resource "azurerm_key_vault_secret" "backblaze_access_key" {
  name         = "backblaze-access-key"   # Dashes not underscores — Key Vault naming
  value        = "REPLACE_WITH_REAL_VALUE"  # In CI/CD, pass via environment variable
  key_vault_id = azurerm_key_vault.main.id

  tags = var.tags

  # This lifecycle block prevents Terraform from showing the diff
  # when you rotate the secret via Azure Portal or CLI
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "backblaze_secret_key" {
  name         = "backblaze-secret-key"
  value        = "REPLACE_WITH_REAL_VALUE"
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "bucket_name" {
  name         = "bucket-name"
  value        = "qr-code35"
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}

# ── Diagnostic Setting ────────────────────────────────────────────────────────
# Send Key Vault audit logs to Log Analytics
# You'll see every secret access: who read what secret and when
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "kv-diagnostics"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"  # All read/write operations on secrets
  }
}