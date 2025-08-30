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
- DEPLOYMENT == a `.yaml` file declaration that puts clusters in place => Kubernetes then selects the machines and propagates the containers in each pod

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

### Common k3d Troubleshooting

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

### kubectl and its role in k3d and k3s

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

### Ex. 1.1 - First Application Deploy

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

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.1/log_output`

---

### Exercise 1.2: TODO Application

**Objective**: Create a web server that outputs "Server started in port NNNN" when started, uses PORT environment variable, and deploy to Kubernetes.

- **Application Development**

- **Created Express.js server**: Simple web server with configurable port
- **PORT environment variable**: `const port = process.env.PORT || 3000;`
- **Startup message**: Logs "Server started in port 3000" as required

- **Docker Containerization**

- **Dockerfile**: Node.js 24-alpine base with npm install and app copy
- **Local build**: `docker build -t todo-app .`
- **Docker Hub push**: Tagged and pushed as `aljazkovac/todo-app:latest`

- **Kubernetes Deployment**

- **Reused existing cluster**: Used the same k3s-default cluster from exercise 1.1
- **Deployed app**: `kubectl create deployment todo-app --image=aljazkovac/todo-app:latest`
- **No networking yet**: As expected, external access not configured (covered in future exercises)

- **Essential Commands Learned**

- `docker tag <local-image> <dockerhub-username>/<image>:latest` - Tag for registry
- `docker push <dockerhub-username>/<image>:latest` - Push to Docker Hub
- `kubectl create deployment <name> --image=<image>` - Deploy from registry
- `kubectl logs deployment/<name>` - Check application logs

**Result**: ✅ Successfully created and deployed a simple web server to Kubernetes, confirming proper startup message and environment variable usage.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.2/todo_app`

---

### Exercise 1.3: Declarative Deployment Manifests

**Objective**: Move the "Log output" app to a declarative Kubernetes manifest and verify it runs by restarting and following logs.

- **Manifests folder**: Created `devops-with-kubernetes/log_output/manifests/` and added [`deployment.yaml`](https://github.com/aljazkovac/devops-with-kubernetes/blob/1.3/log_output/manifests/deployment.yaml).
- **Deployment spec**: `apps/v1` Deployment named `log-output`, label `app=log-output`, 1 replica, image `aljazkovac/kubernetes-1-1:latest`.

### Apply & verify

```bash
# Apply the declarative deployment
kubectl apply -f devops-with-kubernetes/log_output/manifests/deployment.yaml

# Wait for rollout to complete
kubectl rollout status deployment/log-output

# Inspect pods
kubectl get pods -l app=log-output

# Follow logs (shows timestamp + UUID)
kubectl logs -f -l app=log-output --prefix=true
```

### Restart test

```bash
# Trigger a rolling restart and watch logs
kubectl rollout restart deployment/log-output
kubectl rollout status deployment/log-output
kubectl logs -f -l app=log-output --prefix=true
```

**Result**: ✅ Deployment applied successfully; pods emit periodic timestamp + UUID as before using the declarative manifest.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.3/log_output`

---

### Exercise 1.4: Declarative Deployment for TODO app

**Objective**: Create a `deployment.yaml` for the course project you started in Exercise 1.2 (`todo-app`). You won’t have access to the port yet — that comes later.

- **Manifests folder**: Created `devops-with-kubernetes/todo_app/manifests/` and added [`deployment.yaml`](https://github.com/aljazkovac/devops-with-kubernetes/blob/1.4/todo_app/manifests/deployment.yaml).
- **Deployment spec**: `apps/v1` Deployment named `todo-app`, label `app=todo-app`, 1 replica, image `aljazkovac/todo-app:latest`, with resource requests/limits.

### Apply & verify (Deployment)

```bash
# Apply the declarative deployment
kubectl apply -f devops-with-kubernetes/todo_app/manifests/deployment.yaml

# Wait for rollout to complete
kubectl rollout status deployment/todo-app

# Inspect pods
kubectl get pods -l app=todo-app

# Chech logs to verify startup message (no external port yet)
kubectl logs -l app=todo-app
```

**Result**: ✅ The `todo-app` runs via a declarative Deployment, and logs confirm the server starts with the given port. External access will be added in a later exercise.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.4/todo_app`

---

## Introduction to Debugging

Some useful commands:

- `kubectl describe`
- `kubectl logs`
- `kubectl delete`
- `kubectl get events`

Using [Lens](https://k8slens.dev/), the Kubernetes IDE, can also make for a smoother debugging experience.

## Introduction to Networking

The `kubectl port-forward` command is used to forward a local port to a pod. It is not meant for production use.

---

### Exercise 1.5: Port forwarding for the TODO app

**Objective**: Return a simple HTML website and use port-fowarding to reach it from your local machine

- **Create a simple HTML website**
- **Build a new Docker image and push**: `docker build -t aljazkovac/todo-app:latest .` && `docker push aljazkovac/todo-app:latest`
- **Apply new deployment**: `kubectl apply -f todo_app/manifests/deployment.yaml`
- **Restart deployment**: `kubectl rollout restart deployment/todo-app`
- **Port forward**: `kubectl port-forward todo-app-66579f8fd6-j72f8 3000:8080` (<`local port`>:<`pod port`>)
- **Check at localhost:3000**: Go to localhost:3000 and make sure you see the HTML website.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.5/todo_app`

---

### Exercise 1.6: Use a NodePort service for the TODO app

**Objective**: Use a NodePort service to reach your TODO-app from your local machine

- **Prepare a service.yaml file**
- **Delete existing Kubernetes cluster**: `k3d cluster delete k3s-default`
- **Create new Kubernetes cluster and open ports on the Docker container and the Kubernetes node**:
  `k3d cluster create k3s-default --port "3000:30080@agent:0" --agents 2`
- **Apply the deployment**: `kubectl apply -f manifests/deployment.yaml`
- **Apply the service**: `kubectl apply -f manifests/service.yaml`
- **Check at localhost:3000**: Go to `localhost:3000` and make sure you see the HTML website.

Here is the complete chain of port-forwarding:

Browser (localhost:3000)
↓ (Docker port mapping)
Docker Container: k3d-k3s-default-agent-0 port 30080
↓ (This container IS the Kubernetes node)
Kubernetes Node port 30080
↓ (NodePort service routing)
Service nodePort: 30080 → targetPort: 8080
↓
TODO app listening on port 8080

**Important**: It doesn't matter which node has the port mapping. The Kubernetes NodePort service handles the cross-node routing. In this case, we opened the port on node `agent-0`, but the pod was running on `agent-1`, but we could still access it at `localhost:3000`.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.6/todo_app`

---

## Exercise 1.7: Add HTTP Endpoint to Log Output App

**Objective**: "Log output" application currently outputs a timestamp and a random string (that it creates on startup) to the logs. Add an endpoint to request the current status (timestamp and the random string) and an Ingress so that you can access it with a browser.

### Solution

I extended the `log_output/app.js` to include an HTTP server with a `/status` endpoint that returns the current timestamp and the application's UUID as JSON.

The key changes were:

- Added HTTP server using Node.js built-in `http` module
- Created `/status` endpoint that returns `{timestamp, appId}` 
- Kept the existing 5-second logging functionality
- Random string (UUID) is stored in memory for the application lifetime

I also needed to update the Kubernetes manifests:

- **Updated deployment.yaml**: Added `containerPort: 3000` to expose the HTTP server port
- **Created service.yaml**: ClusterIP service exposing port 2345, targeting container port 3000
- **Created ingress.yaml**: Ingress resource to route HTTP traffic from the browser to the service

### Networking and Port Configuration

The networking flow works as follows:

1. **k3d Port Mapping**: k3d maps host port 3000 to the cluster's LoadBalancer port 80
2. **Ingress (Traefik)**: Receives requests on port 80 and routes them based on ingress rules
3. **Service**: Exposes the deployment on cluster port 2345 and forwards to container targetPort 3000
4. **Container**: The Node.js app listens on port 3000 inside the container

The complete flow: `localhost:3000` → `Traefik LoadBalancer:80` → `log-output-svc:2345` → `container:3000`

This differs from direct port forwarding (`kubectl port-forward`) because:

- **Ingress routing**: Uses HTTP path-based routing instead of direct port mapping
- **Service abstraction**: The Service provides load balancing and service discovery
- **Production-ready**: Ingress is designed for production use, while port-forward is for development

After building and pushing the updated Docker image (`aljazkovac/log-output:latest`) and applying the manifests, the endpoint is accessible at:

```bash
curl http://localhost:3000/status
# Returns: {"timestamp":"2025-08-21 19:47:06","appId":"f67b6cb3-9982-40d9-b50f-0eb85059bbae"}
```

**Key Insight**: The random string (UUID) is stored in memory and persists for the lifetime of the application. Each restart generates a new UUID, but it remains constant while the container is running.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.7/log_output`

---

### Exercise 1.8: Use Ingress for the TODO app

**Objective**: Use a Ingress service to reach your TODO-app from your local machine

- **Delete the existing cluster**: `k3d cluster delete k3s-default`
- **Create a new cluster with the port mapping to port 80 (where Ingress listens)**: `k3d cluster create k3s-default --port "3000:80@loadbalancer" --agents 2`
- **Create a service file**
- **Create an ingress file**: make sure you reference your service correctly
- **Apply all services**: `kubectl apply -f manifests/`
- **Check at `http://localhost:3000`**

The traffic flow: `localhost:3000 → k3d loadbalancer:80 → Ingress → Service(2345) → Pod(8080)`

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.8/todo_app`

---

### Exercise 1.9: Ping-Pong Application with Shared Ingress

**Objective**: Develop a second application that responds with "pong X" to GET requests and increases a counter. Create a deployment for it and have it share the same Ingress with the "Log output" application by routing requests directed to '/pingpong' to it.

- **Create the ping-pong application**: Express.js app that handles `/pingpong` endpoint directly
- **Build and push the Docker image**: `docker build -t aljazkovac/pingpong:latest ./pingpong && docker push aljazkovac/pingpong:latest`
- **Create deployment and service manifests**: Deploy with resource limits and expose on port 2346
- **Update the existing Ingress**: Add a new path rule for `/pingpong` to route to `pingpong-svc`
- **Apply the manifests**: `kubectl apply -f pingpong/manifests/`
- **Test both endpoints**: 
  - `curl http://localhost:3000/status` - returns log-output status
  - `curl http://localhost:3000/pingpong` - returns "pong 0", "pong 1", etc.

The traffic flow with shared Ingress:

```bash
localhost:3000 → k3d loadbalancer:80 → Ingress
                                          ├─ /status → log-output-svc:2345 → Pod:3000
                                          └─ /pingpong → pingpong-svc:2346 → Pod:9000
```

Key implementation details:

- The ping-pong app listens on `/pingpong` directly (not `/`), avoiding the need for path rewriting
- Both applications share the same Ingress resource with path-based routing
- The counter is stored in memory and may reset on pod restart
- Port 9000 (where the ping-pong container listens) is not directly accessible from outside the cluster - you must go through the Ingress at `localhost:3000/pingpong`. This is why attempting to access `localhost:9000` directly doesn't work.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.9/pingpong`

---

## Introduction to Storage

There are two really hard things in Kubernetes: networking and [storage](https://softwareengineeringdaily.com/2019/01/11/why-is-storage-on-kubernetes-is-so-hard/).

There are several types of storage in Kubernetes:

- emptyDir volume: shared filesystem within a pod => lifecycle tied to the pod => not to be used for backing up a database, but can be used for cache.
- persistent volume: local (not to be used in production as they are tied to a specific node)

---

### Exercise 1.10: Multi-Container Pod with Shared Storage

**Objective**: Split the log-output application into two applications: one that writes timestamped logs to a file every 5 seconds, and another that reads from that file and serves the content via HTTP endpoint. Both applications should run in the same pod and share data through a volume.

- **Restructure the application**: Split `log_output/` into `log-writer/` and `log-reader/` subdirectories
- **Create log-writer app**: Writes `timestamp: appId` to `/shared/logs.txt` every 5 seconds, serves status on port 3001
- **Create log-reader app**: Reads from `/shared/logs.txt` and serves aggregated data via `/status` endpoint on port 3000
- **Build and push images**: `docker build` and `docker push` both applications
- **Update deployment**: Multi-container pod with emptyDir volume mounted at `/shared` in both containers
- **Deploy and test**: `kubectl apply -f log_output/manifests/`

The traffic flow with multi-container pod:

```localhost:3000/status → Ingress → Service:2345 → log-reader:3000 → /shared/logs.txt
                                                         ↖
                                              log-writer:3001 → /shared/logs.txt
                                                     ↑
                                            (writes every 5 seconds)
```

Key implementation details:

- **emptyDir volume**: Shared storage mounted at `/shared` in both containers, lifecycle tied to the pod
- **File-based communication**: log-writer appends to `/shared/logs.txt`, log-reader reads entire file and counts lines
- **Port separation**: log-writer (3001) and log-reader (3000) use different ports to avoid conflicts
- **Service routing**: Only log-reader exposed externally; log-writer's HTTP server accessible only within pod
- **Real-time updates**: Each request to `/status` shows current file state with increasing `totalLogs` count

The `totalLogs` count increases over time as the writer continuously appends new entries. The log-reader serves the most recent log entry and total count from the shared file.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/2.1`

---

**Scaling Deployments:**

The `kubectl scale` command allows you to dynamically adjust the number of replicas (pods) for a deployment. This is essential for managing resource consumption and handling varying workloads.

**Scale up a deployment:**

```bash
kubectl scale deployment <deployment-name> --replicas=<number>
```

**Scale down to zero (stop all pods):**

```bash
kubectl scale deployment <deployment-name> --replicas=0
```

**Scale back up:**

```bash
kubectl scale deployment <deployment-name> --replicas=1
```

**Practical Examples:**

```bash
# Scale the log-output deployment to 3 replicas
kubectl scale deployment log-output --replicas=3

# Scale down the todo-app to save resources
kubectl scale deployment todo-app --replicas=0

# Scale back up when needed
kubectl scale deployment todo-app --replicas=1

# Check current replica status
kubectl get deployment <deployment-name>
```

**Use Cases:**

- **Resource Management**: Scale to zero when testing applications to free up CPU and memory
- **Load Handling**: Scale up replicas to handle increased traffic
- **Development**: Quickly stop/start applications during development cycles
- **Cost Optimization**: Scale down non-production environments when not in use

The scaling approach is much more efficient than deleting and recreating deployments, as it maintains your configuration while allowing precise control over resource usage.

---

### Exercise 1.11: Shared Persistent Volume Storage

**Objective**: Enable data sharing between "Ping-pong" and "Log output" applications using persistent volumes. Save the number of requests to the ping-pong application into a file in the shared volume and display it alongside the timestamp and random string when accessing the log output application.

**Expected final output**:

```bash
2020-03-30T12:15:17.705Z: 8523ecb1-c716-4cb6-a044-b9e83bb98e43.
Ping / Pongs: 3
```

**Implementation Summary:**
This exercise demonstrates persistent data sharing between two separate Kubernetes deployments using PersistentVolumes and PersistentVolumeClaims. The key challenge was enabling the ping-pong application to save its request counter to shared storage that the log-output application could read and display.

**Step-by-Step Process:**

- Create Cluster-Admin Storage Infrastructure:

```bash
docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
```

- Modify Ping-Pong and Lod-Reader Applications
- Update Kubernetes Deployments
- Rebuild and Deploy Updated Images
- Test Persistent Storage

**How the Applications Work Together:**

The system consists of three main components working together through shared persistent storage:

_Ping-Pong Application:_ Runs as a separate deployment, handles `/pingpong` requests by incrementing an in-memory counter, returning "pong X" responses, and persistently saving the counter value to `/shared/pingpong-counter.txt` in the format "Ping / Pongs: X".

_Log-Writer Component_: Continues its original function of writing timestamped UUID entries to `/shared/logs.txt` every 5 seconds, but now uses `writeFile` instead of `appendFile` to maintain only the latest entry.

_Log-Reader Component_: Enhanced to read from both shared files - combines the latest log entry from `logs.txt` with the current ping counter from `pingpong-counter.txt`, serving both pieces of information through the `/status` endpoint.

_Data Flow_: When a user hits `/pingpong`, the ping-pong app increments its counter and saves it to shared storage. When accessing `/status`, the log-reader reads both the latest timestamp/UUID and the current ping count from shared files, presenting them as a unified response.

**Deployment Configuration and Node Scheduling:**

_Node Affinity Solution_: The PersistentVolume includes nodeAffinity constraints that force any pods using this volume to schedule on `k3d-k3s-default-agent-0`. This ensures both applications can access the same `hostPath` directory. Since `hostPath` storage is node-local (each node has its own `/tmp/kube` directory), pods on different nodes would see different file systems. The nodeAffinity constraint solves this by ensuring co-location.

_ReadWriteOnce vs ReadWriteMany_: We use `ReadWriteOnce` access mode, which allows multiple pods on the same node to share the volume. This works because our nodeAffinity ensures both pods run on the same node.

**Container Inspection and Debugging:**

You can inspect the shared volume contents from either pod using `kubectl exec` commands to list directory contents and view file contents. This helps verify that data is being written and read correctly.

**Key Kubernetes Concepts Demonstrated:**

- PersistentVolume vs emptyDir: Unlike `emptyDir` volumes that are tied to pod lifecycle, PersistentVolumes provide data persistence that survives pod restarts and rescheduling.

- Storage Classes and Manual Provisioning: The `manual` storage class indicates that storage is manually provisioned rather than dynamically allocated by a storage controller.

- Cross-Application Data Sharing: This exercise demonstrates how separate deployments can share data through persistent volumes, enabling microservices to communicate via shared file systems.

- Node Affinity for Storage Locality: When using node-local storage like `hostPath`, node affinity constraints ensure pods can access the same underlying storage.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.11`

---

### Exercise 1.12: Random Image from Lorem Picsum

**Objective**: Add a random picture from Lorem Picsum to the TODO app that refreshes hourly and is cached in a persistent volume to avoid repeated API calls.

**Requirements:**
- Display a random image from `https://picsum.photos/1200` in the project
- Cache the image for 10 minutes
- After 10 minutes, serve the cached image once more, then fetch a new image on the next request
- Store images in a persistent volume so they survive container crashes

**Implementation Summary:**
This exercise focused on integrating external API calls with persistent storage and implementing smart caching logic. The main challenge was ensuring the image fetching logic executed properly within the Express.js middleware stack.

**Key Technical Issues and Solutions:**

_Express.js Middleware Order Problem:_ The initial implementation placed `app.use(express.static())` before the route handlers, causing Express to serve `index.html` directly from the public directory without executing the image fetching logic in the "/" route handler.

_Solution:_ Moved the `express.static()` middleware after the route handlers. This ensures that custom route handlers (like "/" for image fetching) execute first, and static file serving only happens if no routes match.

_Caching Logic Implementation:_ The application implements a three-phase caching strategy: images fresh for less than 10 minutes are served from cache, expired images are served once more from cache while marking them as "served after expiry", and subsequent requests trigger a new API fetch.

_Persistent Storage Integration:_ Used PersistentVolume and PersistentVolumeClaim to mount `/app/images` directory, ensuring cached images survive pod restarts and container crashes. The volume mount allows the application to maintain its cache across deployments.

**Application Workflow:**

_Image Fetching Process:_ On each request to the root path, the application checks if a new image is needed based on cache age and usage. If required, it downloads a new image from Lorem Picsum using axios with streaming, saves it to the persistent volume, and updates metadata with fetch timestamp.

_Cache Management:_ Metadata stored in JSON format tracks when images were fetched and whether they've been served after expiry. This enables the "serve expired image once" requirement while ensuring fresh content delivery.

_Integration with HTML:_ The HTML page includes an image element that references `/image` endpoint, which serves the cached image file directly from the persistent volume.

**Debugging and Deployment:**

_Container Orchestration:_ The deployment uses `imagePullPolicy: Always` to ensure latest code changes are pulled, combined with `kubectl rollout restart` to trigger immediate deployment updates.

_Networking Flow:_ Requests flow through the ingress controller to the service (port 2345) to the container (port 8080), where the Express application handles both the HTML serving and image caching logic.

**Kubernetes Resource Configuration:**

The solution uses existing persistent volume infrastructure from previous exercises, mounting the image storage at `/app/images` in the container. This ensures cached images persist across pod restarts while maintaining the 10-minute caching behavior.

Release: Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/1.12`

---
