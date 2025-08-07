---
title: DevOps with Kubernetes
date: 2025-07-23 16:00:00 +0200
categories: [devops, kubernetes] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [devops, kubernetes, prometheus, grafana] # TAG names should always be lowercase.
description: University of Helsinki course on Kubernetes
---

## First deploy

**Learning goals**:

- Create and run a Kubernetes cluser locally with k3d
- Deploy a simple application to Kubernetes

**Terminology**:

- Microservices: Small, autonomous services that work together.
- Monolith: A service that is self-contained.
- [Kubernetes](https://kubernetes.io/): An open-source system for automating deployment, scaling, and management of containerized applications. It groups containers into logical units for easy management and discovery. See this [simple explanation](https://www.youtube.com/watch?v=Q4W8Z-D-gcQ&t=4s) and this [fun comic](https://cloud.google.com/kubernetes-engine/kubernetes-comic/) for a quick overview.

_Microservices_:

Top [three reasons for using them](https://www.youtube.com/watch?v=GBTdnfD6s5Q&t=297s):

1. Zero-downtime independent deployability
2. Isolation of data and processing around that data
3. They reflect the organizational structure

_Basic Kubernetes concepts_:

- POD == the smallest building block in the Kubernetes object model. The pod sees the container(s) it contains, Kubernetes only sees the pod
- NODE == groups of pods co-located on a single machine (real or virtual)
- CLUSTER == nodes are grouped into clusters, each of which is overseen by a MASTER NODE
- DEPLOYMENT == a .yaml file declaration that puts clusters in place => Kubernetes then selects the machines and propagates the containers in each pod

[_K3s_](https://k3s.io/) is a lightweight Kubernetes distribution developed by Rancher Labs. It’s designed to be easy to install, resource-efficient, and suitable for local development, edge, and IoT environments. It removes some non-essential features and dependencies to reduce complexity.

[_K3d_](https://github.com/k3d-io/k3d) is a tool that runs K3s clusters in Docker containers. It makes it easy to spin up and manage local Kubernetes clusters for testing and development.

**Differences from full Kubernetes:**

- K3s is much smaller and faster to start, with a reduced binary size.
- It omits some advanced features (like in-tree cloud providers, some storage drivers).
- K3s is ideal for local development, CI, and edge use cases, while full Kubernetes is used for production-grade, large-scale deployments.
- K3d lets you run K3s clusters inside Docker containers, making it even easier to experiment locally.

For most learning and development scenarios, k3s/k3d is sufficient and much simpler to use than a full Kubernetes. If you use k3d then you don't need to install k3s separately.

## Containers in k3d Cluster

When you run the command `k3d cluster create -a 2`, the following containers are created as part of the Kubernetes cluster:

- **Server container**: Acts as the control plane, managing the cluster state and scheduling workloads.
- **Agent containers**: Two worker nodes that run the actual workloads (pods).
- **Load balancer container**: Proxies traffic to the server container, ensuring external requests are routed correctly.
- **Tools container**: Used internally by `k3d` for cluster management tasks.

These containers collectively form the Kubernetes cluster managed by `k3d`.

If we run the command `k3d kubeconfig get k3s-default` then we can see the auto-generated kubeconfig file, located at `~/.kube/config`.

Some more basic `k3d` commands: `k3d cluster start`, `k3d cluster stop`, `k3d cluster delete`.

## Common k3d Troubleshooting

**Connection Refused Error**:

When running `kubectl get nodes`, you might encounter:

```text
The connection to the server 0.0.0.0:63096 was refused - did you specify the right host or port?
```

This typically means your k3d cluster is stopped. Check cluster status:

```bash
k3d cluster list
```

If you see `0/1` servers and `0/2` agents, the cluster is stopped. Start it with:

```bash
k3d cluster start k3s-default
```

After starting, verify the cluster is running:

- Servers should show `1/1`
- Agents should show `2/2`
- `kubectl get nodes` should now work successfully

## kubectl and its role in k3d and k3s

`kubectl` is the command-line tool used to interact with Kubernetes clusters. It works seamlessly with `k3d` and `k3s` as follows:

1. **Cluster Creation**:  
   `k3d` creates a Kubernetes cluster by running `k3s` inside Docker containers. It also generates a kubeconfig file that contains the connection details for the cluster.

2. **Configuration**:  
   The kubeconfig file is typically located at `~/.kube/config`. `kubectl` uses this file to connect to the Kubernetes API server running in the `k3s` server container.

3. **Interaction**:
   - You use `kubectl` commands (e.g., `kubectl get pods`, `kubectl apply -f deployment.yaml`) to manage Kubernetes resources.
   - `kubectl` communicates with the Kubernetes API server, which processes the commands and manages the cluster accordingly.

In summary, `kubectl` is the tool you use to interact with the Kubernetes cluster created by `k3d` and powered by `k3s`. It relies on the kubeconfig file for connection details and authentication.

`kubectl` communicates with the Kubernetes API server running inside the `k3s` server container. `k3d` is responsible for setting up and managing the infrastructure (containers) that run the `k3s` cluster, but it does not process Kubernetes commands itself.

In this setup:

- `kubectl` sends commands to the Kubernetes API server.
- The API server processes these commands and manages the cluster resources.
- `k3d` ensures the `k3s` cluster infrastructure is running smoothly, providing the environment for the Kubernetes cluster.

A useful command is `kubectl explain <resource>`, e.g., `kubectl explain pod`. Another good command to know is `kubectl get <resource>`, e.g., `kubectl get pods`.

---

## Ex. 1.1 - First Application Deploy

**Goal**: Create a simple application that outputs a timestamp and UUID every 5 seconds, containerize it, and deploy it to Kubernetes.

- **Create simple app**: Generates UUID on startup, outputs timestamp + UUID every 5 seconds

- **Containerize the app**

- `docker build -t your-dockerhub-username/ex-1-1:latest .`
- `docker login`
- `docker push your-dockerhub-username/ex-1-1:latest`

- **Kubernetes Deployment**

- **Created cluster**: `k3d cluster create k3s-default -a 2`
- **Deployed app**: `kubectl create deployment log-output --image=aljazkovac/kubernetes-1-1`
- **Initial issue**: Wrong image name caused `ImagePullBackOff` - lesson learned about exact naming

- **Testing and Scaling**

- **Scaling experiment**: `kubectl scale deployment log-output --replicas=3`
- **Key insight**: Each pod is independent with its own UUID - they don't share log files
- **Multi-pod logging**: `kubectl logs -f -l app=log-output --prefix=true` shows which pod generated each log line

- **Essential Commands Learned**

- `kubectl logs -f deployment/log-output` - Stream logs from all pods
- `kubectl logs -f -l app=log-output --prefix=true` - Stream with pod names
- `kubectl scale deployment <name> --replicas=N` - Scale application
- `kubectl get pods` - Check pod status

**Result**: ✅ Successfully deployed and scaled a containerized application, understanding pod independence and basic Kubernetes orchestration.

---
