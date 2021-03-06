variable "location" {
  type        = string
  description = "A datacenter location in Azure."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "key_vault_name" {
  type        = string
  description = "Name of the key vault."
}

variable "sql_admin_user_secret_name" {
  type        = string
  description = "Name of the sql admin user stored secret."
}

variable "sql_admin_password_secret_name" {
  type        = string
  description = "Name of the sql admin password stored secret."
}

variable "sql_server_name" {
  type        = string
  description = "Name of the sql server."
}

variable "sql_server_version" {
  type        = string
  description = "Azure sql server version."
  default     = "12.0"
}

variable "sql_database_name" {
  type        = string
  description = "Name of the azure sql database."
}

variable "sql_database_sku" {
  type        = string
  description = "Azure sql database sku."
}

variable "sql_database_min_capacity" {
  type        = number
  description = "Minimal capacity that database will always have allocated, if not paused."
  default     = 0.5
}

variable "sql_database_auto_pause_delay" {
  type        = number
  description = "Time in minutes after which database is automatically paused."
  default     = 60
}

variable "subnet_id" {
  type        = string
  description = "id of the subnet."
}

variable "short_term_retention_days" {
  type        = number
  description = "Number of days to keep short term backups."
  default     = 7
}

variable "audit_logging_primary_blob_endpoint" {
  type        = string
  description = "The blob storage endpoint."
}

variable "audit_logging_primary_access_key" {
  type        = string
  description = "The access key to use for the auditing storage account."
}

variable "audit_logging_primary_access_key_is_secondary" {
  type        = bool
  description = "Specifies if storage_account_access_key is a secondary key."
  default     = false
}

variable "audit_logging_retention" {
  type        = number
  description = "The number of days to retain audit logs."
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether or not public network access is allowed for this server."
  default     = false
}

variable "private_dns_zone_group" {
  description = "nested block: NestingList, min items: 0, max items: 1"
  type        = set(object(
  {
    name                 = string
    private_dns_zone_ids = list(string)
  }
  ))
  default     = []
}
