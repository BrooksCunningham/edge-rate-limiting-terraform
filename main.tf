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
resource "fastly_service_vcl" "frontend-vcl-service" {
  name = "edge-rate-limiting-terraform"

   domain {
     name    = var.USER_DOMAIN_NAME
     comment = "demo for configuring edge rate limiting with terraform"
    }
    backend {
      address = var.USER_DEFAULT_BACKEND_DOMAIN_NAME
      name = "fastly_origin"
      port    = 443
      use_ssl = true
      ssl_cert_hostname = var.USER_DEFAULT_BACKEND_DOMAIN_NAME
      ssl_sni_hostname = var.USER_DEFAULT_BACKEND_DOMAIN_NAME
      override_host = var.USER_DEFAULT_BACKEND_DOMAIN_NAME
    }
   
    # snippet {
    #   name = "Default Edge Rate Limiting"
    #   content = file("${path.module}/snippets/default_edge_rate_limiting.vcl")
    #   type = "init"
    #   priority = 100
    # }

    snippet {
      name = "Low Volume Login Edge Rate Limiting"
      content = file("${path.module}/snippets/edge_rate_limiting_low_volume.vcl")
      type = "init"
      priority = 90
    }

    snippet {
      name = "Debug Low Volume Login Edge Rate Limit"
      content = file("${path.module}/snippets/debug_low_volume_edge_rate_limit.vcl")
      type = "deliver"
      priority = 100
    }

    # snippet {
    #   name = "Edge Rate Limiting with URL as key"
    #   content = file("${path.module}/snippets/edge_rate_limiting_url_key.vcl")
    #   type = "init"
    #   priority = 110
    # }

    ##### Rate limit by org name when it is a hosting provider - Red Sauron
    # snippet {
    #   name = "Rate Limit by ASN Name"
    #   content = file("${path.module}/snippets/edge_rate_limiting_asname_key.vcl")
    #   type = "init"
    #   priority = 120
    # }

    ##### origin_waf_response
    # snippet {
    #   name = "Origin Response Penalty Box"
    #   content = file("${path.module}/snippets/origin_response_penalty_box.vcl")
    #   type = "init"
    #   priority = 130
    # }

    ##### Rate limit by URL and group specific URLs together - Advanced case
    # snippet {
    #   name = "Edge Rate Limiting with URL as key - Advanced"
    #   content = file("${path.module}/snippets/edge_rate_limiting_url_key_advanced.vcl")
    #   type = "init"
    #   priority = 140
    # }


    ##### It is necessecary to disable caching for ERL to increment the counter for origin requests
    snippet {
      name = "Disable caching"
      content = file("${path.module}/snippets/disable_caching.vcl")
      type = "recv"
      priority = 100
    }

    #### useful for sending enriched logs to the origin
    # snippet {
    #   name = "Add client data to requests"
    #   content = file("${path.module}/snippets/add_client_data.vcl")
    #   type = "recv"
    #   priority = 110
    # }

    dictionary {
      name       = "login_paths"
    }

    dictionary {
      name       = "login_edge_rate_limit_config"
    }

    force_destroy = true
}

resource "fastly_service_dictionary_items" "login_paths_dictionary_items" {
  for_each = {
  for d in fastly_service_vcl.frontend-vcl-service.dictionary : d.name => d if d.name == "login_paths"
  }
  service_id = fastly_service_vcl.frontend-vcl-service.id
  dictionary_id = each.value.dictionary_id

  items = {
    "/login": 1,
    "/auth": 2,
    "/gateway": 3,
    "/identity": 4,
  }

  manage_items = false
}

resource "fastly_service_dictionary_items" "login_edge_rate_limit_config_dictionary_items" {
  for_each = {
  for d in fastly_service_vcl.frontend-vcl-service.dictionary : d.name => d if d.name == "login_edge_rate_limit_config"
  }
  service_id = fastly_service_vcl.frontend-vcl-service.id
  dictionary_id = each.value.dictionary_id

  # rate_limit_rpm_value may not be less than 10
  items = {
    "rate_limit_rpm_value": "10",
    "blocking": "true",
    "rate_limit_delta_value": "200",
  }
  manage_items = true
}

# output "live_laugh_love_edge_rate_limiting" {
#   # How to test example
#   value = "siege https://${var.USER_DOMAIN_NAME}/foo/v1/menu?x-obj-status=206"
# }


output "live_laugh_love_ngwaf" {
  value = <<tfmultiline
  
  #### Click the URL to go to the service ####
  https://cfg.fastly.com/${fastly_service_vcl.frontend-vcl-service.id}

  #### High volume test ####
  siege https://${var.USER_DOMAIN_NAME}/foo/v1/menu?x-obj-status=206


  #### Send a debug request with curl to see erl counters increment. look for response headers that start with "rl-" ####
  watch 'curl -i "https://${var.USER_DOMAIN_NAME}/login" -H fastly-debug:1'
  
  for test in {1..1000} ; do 
    printf "$${test},"
    for i in {1..25} ; do
        sleep 1;
        # printf "$i,"
        # date | tr -d '\n'; printf ','
        curl -i -o /dev/null https://${var.USER_DOMAIN_NAME}/login -H "Fastly-debug:1" -H "rl-key: $${test}" -d foo=bar -w '%%{response_code}' | tr -d '\n'
        printf ','
    done
    echo
  done

  tfmultiline

  #### Send a test request with curl. ####
  # curl -i "https://${var.USER_VCL_SERVICE_DOMAIN_NAME}/anything/whydopirates?likeurls=theargs" -d foo=bar

  #### Send an test as cmd exe request with curl. ####
  # curl -i "https://${var.USER_VCL_SERVICE_DOMAIN_NAME}/anything/myattackreq?i=../../../../etc/passwd'" -d foo=bar


  #### Troubleshoot the logging configuration if necessary. ####
  # curl https://api.fastly.com/service/${fastly_service_vcl.frontend-vcl-service.id}/logging_status -H fastly-key:$FASTLY_API_KEY

  # siege https://${var.USER_DOMAIN_NAME}/foo/v1/menu?x-obj-status=206

  #   for test in {1..1000} ; do 
  #   printf "$${test},"
  #   for i in {1..25} ; do
  #       sleep 1;
  #       # printf "$i,"
  #       # date | tr -d '\n'; printf ','
  #       curl -i -o /dev/null https://${var.USER_DOMAIN_NAME}/login -H "Fastly-debug:1" -H "rl-key: $${test}" -d foo=bar -w '%%{response_code}' | tr -d '\n'
  #       printf ','
  #   done
  #   echo
  # done

  description = "Output hints on what to do next."

}
