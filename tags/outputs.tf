output "tags" {
  description = "The value of tags if you inherit."
  value = local.tags != null ? { for k, v in local.tags: k => v if lookup(local.tags, k) != null } : null
}

output "tags_complete" {
  description = "The value of tags if you not inherit."
  value       = { for k, v in local.tags_complete : k => v if lookup(local.tags_complete, k) != null }
}

output "mandatory_tags" {
  description = "The value of mandatory tags."
  value       = local.tags_resource
}
