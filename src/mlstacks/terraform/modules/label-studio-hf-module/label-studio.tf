resource "huggingface-spaces_space" "ls_space" {
  provider = huggingface-spaces
  name     = "label-studio-hf-module-${formatdate("YYYYMMDD", timestamp())}"
  private  = false
  sdk      = "docker"
  template = "LabelStudio/LabelStudio"

  hardware = var.label_studio_hardware
  sleep_time = var.label_studio_sleep_time
  storage = "small"
}


