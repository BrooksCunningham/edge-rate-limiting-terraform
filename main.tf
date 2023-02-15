# Terraform 0.13+ requires providers to be declared in a "required_providers" block
terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 3.0.4"
    }
  }
}

# Configure the Fastly Provider
provider "fastly" {
  api_key = var.FASTLY_API_KEY
}

# Create a Service
resource "fastly_service_vcl" "edge-rate-limiting-terraform-service" {
  name = "edge-rate-limiting-terraform"

   domain {
   name    = var.USER_DOMAIN_NAME
   comment = "demo for configuring edge rate limiting with terraform"
    }
    backend {
      address = var.USER_DEFAULT_BACKEND_ADDRESS
      name = "fastly_origin"
      port    = 443
      use_ssl = true
      ssl_cert_hostname = var.USER_DEFAULT_BACKEND_SSL_CERT_HOSTNAME
      ssl_sni_hostname = var.USER_DEFAULT_BACKEND_SSL_CERT_HOSTNAME
      override_host = var.USER_DEFAULT_OVERWRITE_HOSTNAME
    }
   
    snippet {
      name = "Default Edge Rate Limiting"
      content = file("${path.module}/snippets/default_edge_rate_limiting.vcl")
      type = "init"
      priority = 100
    }

    snippet {
      name = "Edge Rate Limiting with URL as key"
      content = file("${path.module}/snippets/edge_rate_limiting_url_key.vcl")
      type = "init"
      priority = 110
    }

    ##### Rate limit by org name when it is a hosting provider - Red Sauron
    snippet {
      name = "Rate Limit by ASN Name"
      content = file("${path.module}/snippets/edge_rate_limiting_asname_key.vcl")
      type = "init"
      priority = 120
    }

    ##### origin_waf_response
    snippet {
      name = "Origin Response Penalty Box"
      content = file("${path.module}/snippets/origin_response_penalty_box.vcl")
      type = "init"
      priority = 130
    }

    snippet {
      name = "Edge Rate Limiting with URL as key - Advanced"
      content = file("${path.module}/snippets/edge_rate_limiting_url_key_advanced.vcl")
      type = "init"
      priority = 140
    }


    # It is necessecary to disable caching for ERL to increment the counter for origin requests
    snippet {
      name = "Disable caching"
      content = file("${path.module}/snippets/disable_caching.vcl")
      type = "recv"
      priority = 100
    }

    # useful for sending enriched logs to the origin
    # snippet {
    #   name = "Add client data to requests"
    #   content = file("${path.module}/snippets/add_client_data.vcl")
    #   type = "recv"
    #   priority = 110
    # }
}