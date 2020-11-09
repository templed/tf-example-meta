locals {
  global_state   = yamldecode(file("global.yml"))
  data_state     = yamldecode(file(local.global_state.data_file))
  profile        = local.data_state.aws_profile
  region         = local.data_state.aws_region
  bucket_state   = local.data_state.remote_state
  _bucket_prefix = lookup(local.bucket_state, "path_prefix", "")
  bucket_prefix  = local._bucket_prefix == "" ? "" : format("%s/", local._bucket_prefix)
  bucket_config  = local.data_state.remote_state.passthrough
}

remote_state {
  backend = "s3"
  config = merge(
    {
      encrypt = true
      key     = "${local.bucket_prefix}${path_relative_to_include()}/terraform.tfstate"
      region  = local.region
      profile = local.profile
    },
  local.bucket_config)
}


inputs = merge(
  local.global_state,
  {
    aws_profile = local.profile,
    aws_region  = local.region
  }
)
