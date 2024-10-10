provider "huggingface-spaces" {
  # alias   = "strickvl"  
  token = var.huggingface_token
}

# using the labelstudio huggingface module to create a label studio space on huggingface

module "label_studio_hf" {
  source = "../modules/label-studio-hf-module"
  # providers = {
  #   huggingface-spaces.strickvl = huggingface-spaces.strickvl
  # }
  count = var.enable_annotator ? 1 : 0
  huggingface_token = var.huggingface_token
  enable_annotator = var.enable_annotator
}

output "module_huggingface_token" {
  value = length(module.label_studio_hf) > 0 ? module.label_studio_hf[0].huggingface_token_passed : ""
  sensitive = true
}

output "token_hash" {
  value     = sha256(module.label_studio_hf[0].huggingface_token_passed)
  sensitive = true
}

