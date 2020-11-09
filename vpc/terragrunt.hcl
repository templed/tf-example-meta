terraform {
  source = local.repo_version
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_version = lookup(lookup(local.env_data, "${basename(get_terragrunt_dir())}", {}), "module_version")
  global_data  = yamldecode(file("${get_parent_terragrunt_dir()}/global.yml"))
  env_data     = yamldecode(file("${get_parent_terragrunt_dir()}/${local.global_data.data_file}"))
  skipme       = lookup(lookup(local.env_data, "${basename(get_terragrunt_dir())}", {}), "skipme", false)
}

skip = local.skipme

inputs = merge(
  lookup(local.global_data, "${basename(get_terragrunt_dir())}", {}),
  lookup(local.env_data, "${basename(get_terragrunt_dir())}", {})
)