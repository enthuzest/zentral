resource "null_resource" "sql_user" {
  for_each = toset(var.roles)

  triggers = {
    tenant_id        = var.tenant_id
    sp_client_id     = var.sp_client_id
    sp_client_secret = var.sp_client_secret
    host             = var.host
    database_name    = var.database_name
    ad_display_name  = var.ad_display_name
    ad_object_id     = var.ad_object_id
    role             = each.key
  }

  provisioner "local-exec" {

    when = create

    command = <<-EOF
        ${path.module}/scripts/add-user-and-role.ps1 `
        -tenantId '${var.tenant_id}' `
        -clientId '${var.sp_client_id}' `
        -clientSecret '${var.sp_client_secret}' `
        -sqlServerName '${var.host}' `
        -databaseName '${var.database_name}' `
        -displayName '${var.ad_display_name}' `
        -adObjectId '${var.ad_object_id}' `
        -role '${each.key}' `
      EOF

    interpreter = ["pwsh", "-Command"]
  }

  provisioner "local-exec" {

    when = destroy

    command = <<-EOF
        ${path.module}/scripts/delete-user.ps1 `
        -tenantId '${self.triggers.tenant_id}' `
        -clientId '${self.triggers.sp_client_id}' `
        -clientSecret '${self.triggers.sp_client_secret}' `
        -sqlServerName '${self.triggers.host}' `
        -databaseName '${self.triggers.database_name}' `
        -displayName '${self.triggers.ad_display_name}' `
      EOF

    interpreter = ["pwsh", "-Command"]
  }

}
