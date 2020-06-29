provider google {
  project = var.project_id
  version = "~> 3.0"
}

variable "project_id" {
  type        = string
  description = "The Google Cloud Project ID to use (you can set this in terraform.tfvars)"
}

variable "region" {
  type        = string
  description = "The default GCP region"
}

resource google_cloud_run_service "php_mysql" {
  name     = "php-mysql"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.php_mysql_svc.email
      containers {
        image = "gcr.io/${var.project_id}/php-mysql"
        env {
          name  = "FUNCTION_TARGET"
          value = "helloHttp"
        }
        env {
          name  = "DB_SOCKET"
          value = "/cloudsql/${google_sql_database_instance.database.connection_name}"
        }
        env {
          name  = "DB_USER"
          value = google_sql_user.user.name
        }        
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = "${google_sql_database_instance.database.connection_name}"
      }
    }
  }
}

resource google_service_account "php_mysql_svc" {
  account_id   = "php-mysql-svc"
  display_name = "Cloud Run php_mysql Service Account"
}

resource google_project_iam_member "php_mysql_svc_all_users" {
  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.php_mysql_svc.email}"
}

resource google_sql_database_instance "database" {
  name   = "database"
  region = var.region
  settings {
    tier = "db-f1-micro"
  }
}

resource google_sql_user "user" {
  name     = "root"
  instance = google_sql_database_instance.database.name
  host     = "cloudsqlproxy~%"
}

resource google_cloud_run_service_iam_member "php_mysql_all_users" {
  location = google_cloud_run_service.php_mysql.location
  service  = google_cloud_run_service.php_mysql.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
