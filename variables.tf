# Fastly Edge VCL configuration
variable "FASTLY_API_KEY" {
    type        = string
    description = "This is API key for the Fastly VCL edge configuration."
}

variable "USER_DOMAIN_NAME" {
  type = string
  description = "Frontend domain for your service."
  default = "erl-tf.global.ssl.fastly.net"
}

variable "USER_DEFAULT_BACKEND_ADDRESS" {
  type = string
  description = "Backend for your service."
  default = "https://status.demotool.site"
  # default = "https://info.demotool.site/"
}

variable "USER_DEFAULT_BACKEND_SSL_CERT_HOSTNAME" {
  type = string
  description = "Certificate hostname used for validation for your backend."
  default = "status.demotool.site"
  # default = "info.demotool.site"
}

variable "USER_DEFAULT_OVERWRITE_HOSTNAME" {
  type = string
  description = "The hostname to override the Host header"
  default = "status.demotool.site"
  # default = "info.demotool.site"
}
