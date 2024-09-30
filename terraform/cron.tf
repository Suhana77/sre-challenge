resource "kubectl_manifest" "service-account" {

  depends_on = [
    helm_release.prometheus
  ]

    yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: node-api # this is service account for binding the pod
  namespace: sre-challenge
YAML
}


resource "kubectl_manifest" "ClusterRole" {

  depends_on = [
    helm_release.prometheus
  ]

    yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-api # This defines a role and what API it can access
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["delete", "get", "list"]
YAML
}


resource "kubectl_manifest" "RoleBinding" {

  depends_on = [
    helm_release.prometheus
  ]

    yaml_body = <<YAML
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: sre-challenge
  namespace: sre-challenge
subjects:
- kind: ServiceAccount
  name: node-api
  namespace: sre-challenge
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: node-api
  apiGroup: ""
YAML
}


resource "kubectl_manifest" "chaos-test" {

  depends_on = [
    helm_release.prometheus
  ]

    yaml_body = <<YAML
apiVersion: batch/v1
kind: CronJob
metadata:
  name: kill-pod
  namespace: sre-challenge
spec:
  schedule: "*/5 * * * *"
  successfulJobsHistoryLimit: 0
  failedJobsHistoryLimit: 0
  jobTemplate:
    spec:
      activeDeadlineSeconds: 30
      template:
        spec:
          serviceAccountName: node-api
          containers:
          - name: kill-pod
            image: bitnami/kubectl:latest
            command:
              - sh
              - -c
              - |
                kubectl delete pod $(kubectl get pods -n sre-challenge -l App="node-api" | grep "node-"  |awk '{print $1}' | head -1)
          restartPolicy: OnFailure
YAML
}