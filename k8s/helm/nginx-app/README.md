# Nginx SRE Application Helm Chart

This Helm chart deploys a custom Nginx application with a "Hello SRE!" text file accessible at the `/sre.txt` path.

## Prerequisites

* Kubernetes 1.32+
* Helm 3.1.0+
* A Kubernetes cluster with the AWS Load Balancer Controller installed

## Installing the Chart

To install the chart with the release name `nginx-app`:

```bash
helm install nginx-app ./k8s/helm/nginx-app
```

## Deploying to Different Environments

The chart supports different environments: alpha, beta, staging, and production. To deploy to a specific environment:

```bash
# For alpha environment
helm install nginx-app ./k8s/helm/nginx-app --set environment=alpha

# For beta environment
helm install nginx-app ./k8s/helm/nginx-app --set environment=beta

# For staging environment
helm install nginx-app ./k8s/helm/nginx-app --set environment=staging

# For production environment (default)
helm install nginx-app ./k8s/helm/nginx-app
```

## Parameters

The following table lists the configurable parameters of the Nginx chart and their default values.

| Parameter                               | Description                                      | Default                         |
| --------------------------------------- | ------------------------------------------------ | ------------------------------- |
| `replicaCount`                          | Number of Nginx replicas                         | `2`                             |
| `image.repository`                      | Nginx image repository                           | `sre-nginx`                     |
| `image.tag`                             | Nginx image tag                                  | `latest`                        |
| `image.pullPolicy`                      | Nginx image pull policy                          | `Always`                        |
| `service.type`                          | Kubernetes service type                          | `LoadBalancer`                  |
| `service.port`                          | Kubernetes service port                          | `80`                            |
| `ingress.enabled`                       | Enable ingress controller resource               | `true`                          |
| `ingress.className`                     | IngressClass name                                | `alb`                           |
| `autoscaling.enabled`                   | Enable autoscaling                               | `true`                          |
| `autoscaling.minReplicas`               | Minimum number of replicas                       | `2`                             |
| `autoscaling.maxReplicas`               | Maximum number of replicas                       | `10`                            |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage          | `80`                            |
| `environment`                           | Deployment environment                           | `production`                    |

## Uninstalling the Chart

To uninstall/delete the `nginx-app` deployment:

```bash
helm uninstall nginx-app
``` 