###Configure container groups for Azure Container Instances  

ACI supports scheduling of multi-container groups that share a host machine, local network, storage, and lifecycle. This enables combing the main app container with other supporting role containers, such as logging sidecars. It's similar in concept to a pod in Kubernetes.  

 

There are two common ways to deploy a multi-container group: use a Resource Manager template or a YAML file.  

A Resource Manager template is recommended when you need to deploy additional Azure service resources (for example, an Azure Files share) when you deploy the container instances.  

 

Due to the YAML format's more concise nature, a YAML file is recommended when your deployment includes only container instances. 