# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# add an optional artifact repository
# resource "google_artifact_registry_repository" "artifact-repository" {
#   provider = google-beta

#   count = local.artifact_repository.enable_container_registry ? 1 : 0
#   location = local.region
#   repository_id = local.artifact_repository.name
#   description = "A repository to host docker container images"
#   format = "DOCKER"
# }
