# Export Terraform output variable values to a ZenML test framework
# configuration file that can be used to run ZenML integration tests
# against the deployed MLOps stack.
resource "local_file" "test_framework_cfg_file" {
  content  = <<-ADD
requirements:

  - name: k3d-container-registry-${random_string.cluster_id.result}
    description: >-
      Local K3D container registry.
    system_tools:
      - docker
    stacks:
      - name: k3d-${random_string.cluster_id.result}
        type: container_registry
        flavor: default
        configuration:
          uri: "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"

  - name: k3d-kubernetes-${random_string.cluster_id.result}
    description: >-
      K3D cluster that can be used as a kubernetes orchestrator.
    system_tools:
      - docker
      - kubectl
    capabilities:
      synchronized: true
    stacks:
      - name: k3d-kubernetes-${random_string.cluster_id.result}
        type: orchestrator
        flavor: kubernetes
        containerized: true
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster.name}"
          synchronous: true
          kubernetes_namespace: "${local.k3d.workloads_namespace}"
          local: true

%{ if var.enable_kubeflow }
  - name: k3d-kubeflow-${random_string.cluster_id.result}
    description: >-
      Kubeflow running in a local K3D cluster.
    system_tools:
      - docker
      - kubectl
    capabilities:
      synchronized: true
    stacks:
      - name: k3d-kubeflow-${random_string.cluster_id.result}
        type: orchestrator
        flavor: kubeflow
        containerized: true
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster.name}"
          synchronous: true
          local: true
%{ endif }

%{ if var.enable_tekton }
  - name: k3d-tekton-${random_string.cluster_id.result}
    description: >-
      Tekton running in a local K3D cluster.
    system_tools:
      - docker
      - kubectl
    capabilities:
      synchronized: true
    stacks:
      - name: k3d-tekton-${random_string.cluster_id.result}
        type: orchestrator
        flavor: tekton
        containerized: true
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster.name}"
          kubernetes_namespace: "${local.tekton.workloads_namespace}"
          local: true
%{ endif }

%{ if var.enable_minio || var.enable_mlflow }
  - name: k3d-minio-artifact-store-${random_string.cluster_id.result}
    description: >-
      Minio artifact store running in a local K3D cluster.
    stacks:
      - name: k3d-minio-${random_string.cluster_id.result}
        type: artifact_store
        flavor: s3
        configuration:
          path: "s3://${local.minio.zenml_minio_store_bucket}"
          key: "${var.zenml-minio-store-access-key}"
          secret: "${var.zenml-minio-store-secret-key}"
          client_kwargs: '{"endpoint_url":"${module.minio_server[0].artifact_S3_Endpoint_URL}", "region_name":"us-east-1"}'
%{ endif }

%{ if var.enable_mlflow }
  - name: k3d-mlflow-${random_string.cluster_id.result}
    description: >-
      MLFlow deployed in a local K3D cluster.
    stacks: 
      - name: k3d-mlflow-${random_string.cluster_id.result}
        type: experiment_tracker
        flavor: mlflow
        configuration:
          tracking_uri: "${module.mlflow[0].mlflow-tracking-URL}"
          tracking_username: "${var.mlflow-username}"
          tracking_password: "${var.mlflow-password}"
%{ endif }

%{ if var.enable_seldon }
  - name: k3d-seldon-${random_string.cluster_id.result}
    description: >-
      Seldon Core deployed in a local K3D cluster.
    system_tools:
      - kubectl
    stacks:
      - name: k3d-seldon-${random_string.cluster_id.result}
        type: model_deployer
        flavor: seldon
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster.name}"
          kubernetes_namespace: "${local.seldon.workloads_namespace}"
          base_url:  "http://${var.enable_seldon ? module.istio[0].ingress-ip-address : ""}"
          kubernetes_secret_name: "${var.seldon-secret-name}"

%{ endif }

%{ if var.enable_kserve }
  - name: k3d-kserve-${random_string.cluster_id.result}
    description: >-
      Kserve deployed in a local K3D cluster.
    system_tools:
      - kubectl
    stacks:
      - name: k3d-kserve-${random_string.cluster_id.result}
        type: model_deployer
        flavor: kserve
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster.name}"
          kubernetes_namespace: "${local.kserve.workloads_namespace}"
          base_url:  "http://${var.enable_kserve ? module.istio[0].ingress-ip-address : ""}"
          kubernetes_secret_name: "${var.kserve-secret-name}"
%{ endif }

environments:

  - name: default-k3d-local-orchestrator
    description: >-
      Default deployment with local orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
      - local-secrets-manager
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
    mandatory_requirements:
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }
    capabilities:
      synchronized: true

  - name: default-k3d-kubernetes-orchestrator
    description: >-
      Default deployment with K3D kubernetes orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubernetes-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }

%{ if var.enable_kubeflow }
  - name: default-k3d-kubeflow-orchestrator
    description: >-
      Default deployment with K3D kubeflow orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubeflow-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }
%{ endif }


%{ if var.enable_tekton }
  - name: default-k3d-tekton-orchestrator
    description: >-
      Default deployment with K3D Tekton orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
      - local-secrets-manager
    mandatory_requirements:
      - k3d-tekton-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }
%{ endif }

    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.
  - name: local-server-k3d-local-orchestrator
    description: >-
      Local server deployment with local orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
      - local-secrets-manager
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
    mandatory_requirements:
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }
    capabilities:
      synchronized: true

    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.
  - name: local-server-k3d-kubernetes-orchestrator
    description: >-
      Local server deployment with K3D kubernetes orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubernetes-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{ if var.enable_minio || var.enable_kubeflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }

%{ if var.enable_kubeflow }
    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.
  - name: local-server-k3d-kubeflow-orchestrator
    description: >-
      Local server deployment with K3D kubeflow orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubeflow-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }
%{ endif }

%{ if var.enable_tekton }
    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.
  - name: local-server-k3d-tekton-orchestrator
    description: >-
      Local server deployment with K3D Tekton orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
%{ if var.enable_mlflow }
      - k3d-mlflow-${random_string.cluster_id.result}
%{ else }
      - mlflow-local-tracker
      - mlflow-local-deployer
%{ endif }
%{ if var.enable_seldon }
      - k3d-seldon-${random_string.cluster_id.result}
%{ endif }
%{ if var.enable_kserve }
      - k3d-kserve-${random_string.cluster_id.result}
%{ endif }
      - local-secrets-manager
    mandatory_requirements:
      - k3d-tekton-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{ if var.enable_minio || var.enable_mlflow }
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{ endif }
%{ endif }
    ADD
  filename = "./k3d_test_framework_cfg.yaml"
}