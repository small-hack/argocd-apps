# Argo Workflows

Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes.

Argo Workflows lets you define a YAML configuration with multiple steps, representing the steps in your CI/CD pipeline. Each of these steps runs in a separate container within your Kubernetes cluster. 

Argo uses a CRD called Workflows, which provides a generateName. This name becomes the prefix of all the pods the Workflow runs. As part of the Workflow, you can also define storage volumes, which will be accessible by the templates for your workflow steps.


> Depends on Argo Server already existing, so make sure you install ArgoCD first.
