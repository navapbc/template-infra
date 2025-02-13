locals {
  feature_flag_defaults = {
    FOO = false
    BAR = false
  }
  feature_flags_config = merge(
    local.feature_flag_defaults,
    var.feature_flag_overrides
  )
}
