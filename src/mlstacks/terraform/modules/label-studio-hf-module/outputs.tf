data "huggingface-spaces_space" "ls_space_data" {
  id = huggingface-spaces_space.ls_space.id
}

output "label_studio_id" {
  value = huggingface-spaces_space.ls_space.id
}

output "label_studio_name" {
  value = data.huggingface-spaces_space.ls_space_data.name
}

output "label_studio_author" {
  value = data.huggingface-spaces_space.ls_space_data.author
}

output "label_studio_last_modified" {
  value = data.huggingface-spaces_space.ls_space_data.last_modified
}

output "label_studio_likes" {
  value = data.huggingface-spaces_space.ls_space_data.likes
}

output "label_studio_private" {
  value = data.huggingface-spaces_space.ls_space_data.private
}

output "label_studio_sdk" {
  value = data.huggingface-spaces_space.ls_space_data.sdk
}

output "label_studio_hardware" {
  value = data.huggingface-spaces_space.ls_space_data.hardware
}

output "huggingface_token_passed" {
  value = var.huggingface_token
}


