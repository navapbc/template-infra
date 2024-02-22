locals {
  network_configs = {
    dev = {
      database_subnet_group_name = "dev"

      domain_config = {
        manage_dns  = true
        hosted_zone = "platform-test-dev.navateam.com"

        certificate_configs = {
          "platform-test-dev.navateam.com" = {
            source = "issued"
          }
        }
      }
    }

    staging = {
      database_subnet_group_name = "staging"

      domain_config = {
        manage_dns  = true
        hosted_zone = "platform-test-dev.navateam.com"

        certificate_configs = {
          "platform-test-dev.navateam.com" = {
            source = "issued"
          }
        }
      }
    }

    prod = {
      database_subnet_group_name = "prod"

      domain_config = {
        manage_dns  = true
        hosted_zone = "platform-test.navateam.com"

        certificate_configs = {
          "platform-test.navateam.com" = {
            source = "issued"
          }
        }
      }
    }
  }
}
