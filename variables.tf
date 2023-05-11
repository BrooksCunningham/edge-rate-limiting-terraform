# Fastly Edge VCL configuration
variable "FASTLY_API_KEY" {
    type        = string
    description = "This is API key for the Fastly VCL edge configuration."
}

variable "USER_DOMAIN_NAME" {
  type = string
  description = "Frontend domain for your service."
  default = "erl-tf-brooks.global.ssl.fastly.net"
}

variable "USER_DEFAULT_BACKEND_DOMAIN_NAME" {
  type = string
  description = "Backend for your service."
  default = "status.demotool.site"
  # default = "https://info.demotool.site/"
}
