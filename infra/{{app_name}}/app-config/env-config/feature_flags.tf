locals {
  feature_flags_config = merge(
    {
      FOO = false
      BAR = false
    },
    var.feature_flags_override
  )
}
