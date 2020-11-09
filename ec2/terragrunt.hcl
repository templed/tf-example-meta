terraform {
  source = local.repo_version
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    subnet_id = "sub-12345678"
  }
}

locals {
  repo_version = lookup(lookup(local.env_data, "${basename(get_terragrunt_dir())}", {}), "module_version")
  global_data  = yamldecode(file("${get_parent_terragrunt_dir()}/global.yml"))
  env_data     = yamldecode(file("${get_parent_terragrunt_dir()}/${local.global_data.data_file}"))
  skipme       = lookup(lookup(local.env_data, "${basename(get_terragrunt_dir())}", {}), "skipme", false)
  secret_data  = try(yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/${local.global_data.data_file}")), {})
}

skip = local.skipme

inputs = merge(
  lookup(local.global_data, "${basename(get_terragrunt_dir())}", {}),
  local.secret_data,
  {
      subnet = dependency.vpc.outputs.subnet_id
  },
  lookup(local.env_data, "${basename(get_terragrunt_dir())}", {})
)