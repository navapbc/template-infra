locals {
  feature_flags_config = merge(
    {
      foo = false
      bar = false
    },
    var.feature_flags_override
  )
}
