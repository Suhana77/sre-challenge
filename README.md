SRE Challenge
# Assignment Overview 
This assignment focuses on implementing automation and High Availability (HA) in the infrastructure using various tools. 
The primary objective is to enhance service reliability and ensure that the application remains operational even in the face of failures.
 ### Key Features Implemented 
**Automation**: Leveraged tools like Terraform, Helm, and Kubernetes to automate the deployment and management of resources. –
**High Availability**: Configured components such as Redis in HA mode to ensure data persistence and reliability. 
 **Monitoring and Metrics**: Implemented Prometheus and Grafana for real-time monitoring and visualization of application metrics.
  **Chaos Engineering**: Utilized a Cronjob to periodically kill pods, allowing for testing of service resilience and availability under failure conditions.
 **Horizontal Pod Autoscaler**: Enabled automatic scaling of application pods based on CPU utilization to manage load effectively.

 # Prerequisites
Before you begin, ensure you have the following tools and versions installed on your Windows machine:

## Versions and Tools Used in the Assignments
1. **Minikube**: v1.34.0
2. **Docker Desktop**: v4.34.2
3. **Terraform**: v1.9.4
4. **Kubectl**: v1.31.0
5. **Kubernetes**: v1.31.0
6. **Prometheus**: v2.54.1
7. **Helm Chart CLI**: v3.16.1
8. **Metrics Server**: 3.7.0
9. **Grafana**: v11.2.0
10. **Lens IDED:** - Visit the [Lens IDE download page](https://k8slens.dev/). - Download the Windows installer (`.exe`).
## Helm Charts Used in the Assignments
1. **kube-Prometheus-stack**: v63.1.0
2. **metrics-server**: v3.7.0

# Installation Instructions

To set up your development environment, please follow the steps below:
1. **Install Docker Desktop**
- Download Docker Desktop from the [official website] (https://www.docker.com/products/docker-desktop) and ensure that Windows Subsystem for Linux (WSL) is enabled.
- Once the installation is complete, launch Docker Desktop.
2. **Install Minikube**
- Download the Minikube executable for Windows from [this link] (https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe).
- Install the downloaded executable.
- To download the Docker driver for Minikube, run the following command in your terminal:
minikube start --driver=docker --download-only
- After the driver installation is complete, start the Minikube Kubernetes cluster with:
minikube start
3. **Install Terraform**
- Follow the installation instructions for Terraform as detailed on the [official website] (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
4. **Install Kubectl**
- Install the Kubectl CLI for Windows by following the guidance provided on the [Kubernetes website] (https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/).
5. **Install Helm**
- Download and install the Helm CLI for Windows by referring to the instructions on the [Helm documentation] (https://helm.sh/docs/intro/install/).
6. **Install Lens**
- Go to the Lens IDE download page and Download the Windows installer (.exe).
After installing all the required tools, you will need to start the Open a terminal and run the following command to start the Docker service and Minikube cluster. Follow these steps:
1. **Start the Minikube Cluster** - Open the Command Prompt (CMD) and run the following command: ``` minikube start ``` - Wait for the command to complete. This will initialize and start the Minikube Kubernetes cluster. Now check Kubernetes cluster has been created or not with some plugins.
2. **Verify the Cluster Creation** - To check if the Kubernetes cluster has been successfully created, use the following command: ``` kubectl cluster-info ``` - You can also verify the status of the cluster by running: ``` minikube status ``` - Additionally, check for installed plugins and ensure they are working correctly by running: ``` kubectl get pods --all-namespaces ```
 3. **Navigate to the Terraform Folder** - Change your directory to the folder where your Terraform configuration files are located: ``` cd path/to/terraform-folder ```folder ```
4. **Initialize Terraform** - Run the following command to initialize Terraform: ``` terraform init ``` - This command sets up the Terraform working directory and downloads the necessary provider plugins.  
5. **Apply the Terraform Configuration** - Run the following command to apply the changes defined in your Terraform configuration: ``` terraform apply ``` - You will be prompted to confirm the action. Type. 
`yes` to proceed
6. **Resources Created in the `sre-challenge` Namespace** - The following resources will be created in the `sre-challenge` namespace: - [List specific resources here, e.g., Deployments, Services, ConfigMaps, etc.] - Ensure you review the output during the `terraform apply` process to confirm the creation of these resources. It will also create metric server resources in kube-system namespace.
 7. **Apply the Terraform Configuration**
- Run the following command to apply the changes defined in your Terraform configuration:
```terraform apply```
- You will be prompted to confirm the action. Type `yes` to proceed.
8. **Resources Created in the `sre-challenge` Namespace**
 - The following deployment steps and resources will be created in the `sre-challenge` namespace:
•	A deployment with 2 replicas and a corresponding service to expose the application.
•	A HA setup for Redis ensures reliable data persistence, high availability, and automatic recovery from failures.
•	It will set up comprehensive monitoring and visualization tools like Prometheus and Grafana for your applications.
•	Pod Monitor (node-api) : Configured to collect application custom metrics like `http_response_time`.
•	CronJob (kill-pod): A cron job that removes one pod every five minutes to facilitate chaos engineering practices.
•	Horizontal Pod Autoscaler (node-hpa): To dynamically scale the pods up and down based on CPU utilization.
•	Make sure to monitor the output for any errors or issues during the application process and verify that all resources are created as expected.

Now API server is connected to Redis and Prometheus.
 
 9. Pod Monitor to Scrape Metrics of pods in Prometheus.
Make sure to monitor the output for any errors or issues during the application process, and verify that all resources are created as expected.
Included a specific note about using the Pod Monitor CRD to add app pods as targets for scraping metrics from the /metrics endpoint every 5 seconds.

  
10. Cron Job to remove one pod in every 5 minutes.
Added details about the kill-node CronJob, emphasizing that it runs every 5 minutes and that its design ensures no service downtime due to the rolling update strategy.

11. Use HPA to scale the pod if average CPU utilization of pod is more than 50%.
 Added details about using HPA to scale pods if the average CPU utilization exceeds 50%.

 
12. Included Instructions for increasing the load on the pods to test the HPA functionality.
1.	kubectl run -i --tty load-generator --rm --image=busybox --restart=Never --namespace sre-challenge -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://node-api-service:3000; done"
2.	kubectl run -i --tty load-generator-1 --rm --image=busybox --restart=Never --namespace sre-challenge -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://node-api-service:3000/set; done"
3.	kubectl run -i --tty load-generator-2 --rm --image=busybox --restart=Never --namespace sre-challenge -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://node-api-service:3000/get; done"
4.	kubectl run -i --tty load-generator-3 --rm --image=busybox --restart=Never --namespace sre-challenge -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://node-api-service:3000/; done"
   
13. After increasing the load CPU utilization become 64% and HPA increased the one pod.
 
14. Created Grafana Dashboard to Show Latency and increase in request due to load.
Import the Grafana Json from Grafana-dashboard dir and import the dashboard with that Json and then you can see the response and throughput Metrices.
 

 

Challenges:

1.	Manifest Conversion to Terraform: I found it difficult to convert the entire Kubernetes manifest to Terraform, particularly because some resource blocks were unavailable in Terraform. To address this limitation, I utilized the kubectl_manifest resource, which allowed me to provide the entire YAML configuration within Terraform.
2.	Adding Custom Metrics: Integrating custom metrics into the application server was challenging for me, as it required a deep understanding of both the application and the metrics gathering process. I had to ensure that the metrics were properly exposed and consumed by the monitoring tools.
3.	Horizontal Pod Autoscaler (HPA) Scale Down Mechanism: I needed to adjust the scale-down behavior for the HPA to meet performance requirements. By configuring the scaleDown behavior with stabilizationWindowSeconds: 10, I was able to reduce the scale-down time significantly from the default 500 seconds to just 10 seconds, enhancing responsiveness during low-traffic periods.
4.	Metric Aggregation and Dashboard Visualization: Aggregating metrics through various queries to visualize on the dashboard posed its own set of challenges. I had to create and optimize queries to ensure accurate and meaningful data representation while maintaining performance.
5.	Chaos Engineering Implementation: Conducting chaos engineering experiments without established tools like Litmus Chaos or Chaos Monkey presented unique challenges. I needed to develop custom scripts and methodologies to simulate failures and effectively assess system resilience.
6.	Metrics Server TLS Issues: I encountered TLS issues with the metrics server that required troubleshooting and configuration adjustments to ensure secure communication between components. Resolving these issues was critical for maintaining the reliability of the metrics data.
7.	Pod Monitor Creation Challenges: While creating pod monitors, I faced compatibility issues due to variable changes in the newer Prometheus version. Specifically, I transitioned from using podMonitorSelectorNilUseHelmValues: false to podMonitorSelector: matchLabels: null, which required a thorough understanding of the updated configuration schema.

