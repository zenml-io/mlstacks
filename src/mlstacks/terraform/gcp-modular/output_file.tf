# Export Terraform output variable values to a stack yaml file
# that can be consumed by zenml stack import
resource "local_file" "stack_file" {
  content  = <<-ADD
    # Stack configuration YAML
    # Generated by the GCP Modular MLOps stack recipe.
    zenml_version: ${var.zenml-version}
    stack_name: gcp_modular_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}
    components:
      artifact_store:
%{if var.enable_artifact_store}
        id: ${uuid()}
        flavor: gcp
        name: gcs_artifact_store
        configuration: {"path": "gs://${google_storage_bucket.artifact-store[0].name}"}
%{else}
        id: ${uuid()}
        flavor: local
        name: default
        configuration: {}
%{endif}

%{if var.enable_container_registry}
      container_registry:
        id: ${uuid()}
        flavor: gcp
        name: gcr_container_registry
        configuration: {"uri": "${local.container_registry.region}.gcr.io/${var.project_id}"}
%{endif}

      orchestrator:
%{if var.enable_orchestrator_kubeflow}
        id: ${uuid()}
        flavor: kubeflow
        name: gke_kubeflow_orchestrator
        configuration: {"kubernetes_context": "gke_${local.prefix}-${local.gke.cluster_name}, "synchronous": True}
%{else}
%{if var.enable_orchestrator_tekton}
        id: ${uuid()}
        flavor: tekton
        name: gke_tekton_orchestrator
        configuration: {"kubernetes_context": "gke_${local.prefix}-${local.gke.cluster_name}}
%{else}
%{if var.enable_orchestrator_kubernetes}
        id: ${uuid()}
        flavor: kubernetes
        name: gke_kubernetes_orchestrator
        configuration: {"kubernetes_context": "gke_${local.prefix}-${local.gke.cluster_name}, "synchronous": True}
%{else}
%{if var.enable_orchestrator_skypilot}
        id: ${uuid()}
        flavor: vm-gcp
        name: gcp_skypilot_orchestrator
        configuration: {"project_id": "${var.project_id}"}
%{else}
%{if var.enable_orchestrator_vertex}
        id: ${uuid()}
        flavor: vertex
        name: vertex_orchestrator
        configuration: {"project_id": "${var.project_id}", "location": "${var.region}"}
%{else}
        id: ${uuid()}
        flavor: local
        name: default
        configuration: {}
%{endif}
%{endif}
%{endif}
%{endif}
%{endif}

%{if var.enable_step_operator_vertex}
      step_operator:
        id: ${uuid()}
        flavor: vertex
        name: vertex_step_operator
        configuration: {"project": "${var.project_id}", "region": "${var.region}", "service_account_path": "${local_file.sa_key_file[0].filename}"}
%{endif}


%{if var.enable_secrets_manager}
      secrets_manager:
        id: ${uuid()}
        flavor: gcp
        name: gcp_secrets_manager
        configuration: {"project_id": "${var.project_id}"}
%{endif}

%{if var.enable_experiment_tracker_mlflow}
      experiment_tracker:
        id: ${uuid()}
        flavor: mlflow
        name: gke_mlflow_experiment_tracker
        configuration: {"tracking_uri": "${var.enable_experiment_tracker_mlflow ? module.mlflow[0].mlflow-tracking-URL : ""}", "tracking_username": "${var.mlflow-username}", "tracking_password": "${var.mlflow-password}"}
%{endif}

%{if var.enable_model_deployer_kserve}}
      model_deployer:
        id: ${uuid()}
        flavor: kserve
        name: gke_kserve
        configuration: {"kubernetes_context": "gke_${local.prefix}-${local.gke.cluster_name}, "kubernetes_namespace": "${local.kserve.workloads_namespace}", "base_url": "${var.enable_model_deployer_kserve ? module.kserve[0].kserve-base-URL : ""}", "secret": "gcp_kserve_secret"}
%{else}
%{if var.enable_model_deployer_seldon}
      model_deployer:
        id : ${uuid()}
        flavor: seldon
        name: gke_seldon
        configuration: {"kubernetes_context": "gke_${local.prefix}-${local.gke.cluster_name}", "kubernetes_namespace": "${local.seldon.workloads_namespace}", "base_url": "http://${module.istio[0].ingress-ip-address}:${module.istio[0].ingress-port}"}
%{endif}
%{endif}
    ADD
  filename = "./gcp_modular_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}.yaml"
}
