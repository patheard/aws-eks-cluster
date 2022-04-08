module "vpc" {
  source = "github.com/cds-snc/terraform-modules?ref=v2.0.1//vpc"
  name   = "test-cluster"

  high_availability = true
  enable_flow_log   = false

  allow_https_request_out          = true
  allow_https_request_out_response = true

  billing_tag_value = "test-cluster"
}
