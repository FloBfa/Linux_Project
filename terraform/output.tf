output "db_cluster_uri" {
  value = ovh_cloud_project_database.db_eductive07.endpoints.0.uri
}

output "db_username" {
  value = ovh_cloud_project_database_user.eductive07.name
}

output "db_user_password" {
  value     = ovh_cloud_project_database_user.eductive07.password
  sensitive = true
}
