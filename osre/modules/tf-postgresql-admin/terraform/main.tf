# for third party providers, it is necessary to specify that provider
# even in a module, as they are not inherited.

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.16.0"
    }
  }
}
