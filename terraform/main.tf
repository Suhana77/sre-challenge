provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}


provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
      config_context = "minikube"
    }
}


terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kubectl" {
  
      config_path = "~/.kube/config"
      config_context = "minikube"
    
}