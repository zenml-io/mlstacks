variable "huggingface_token" {
  type        = string
  description = "The Hugging Face API token."
  sensitive   = true
}

variable "enable_annotator" {
  type        = bool
  description = "Enable annotator for the Label Studio instance."
  default     = false
}

variable "enable_persistent_storage" {
  type        = bool
  description = "Enable persistent storage for the Label Studio instance."
  default     = false
}

variable "persistent_storage_size" {
  type        = string
  description = "The size of the persistent storage for the Label Studio instance."
  default     = "small"
}

variable "label_studio_disable_signup_without_link" {
  type        = bool
  description = "Disable the signup without link for the Label Studio instance."
  default     = false
}

variable "label_studio_username" {
  type        = string
  description = "The username for the Label Studio instance."
  default     = "davidrd123@gmail.com"
  sensitive = true
}

variable "label_studio_password" {
  type        = string
  description = "The password for the Label Studio instance."
  default     = "mlstacks"
  sensitive    = true
}

variable "label_studio_hardware" {
  type        = string
  description = "The hardware for the Label Studio instance."
  default     = "cpu-basic"
}

variable "label_studio_template" {
  type        = string
  description = "The template for the Label Studio instance."
  default     = "LabelStudio/LabelStudio"
}

variable "label_studio_sleep_time" {
  type        = string
  description = "The sleep time in seconds for the Label Studio instance. (gc_timeout)"
  default     = "3600"
}

variable "label_studio_private" {
  type        = bool
  description = "The private flag for the Label Studio instance."
  default     = false
}


