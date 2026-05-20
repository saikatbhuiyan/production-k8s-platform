# Kubernetes Notes from `text.txt`

This document reformats the full content of `text.txt` into structured Markdown without dropping the major sections or examples. It is meant to read like a study guide built from your notes.

---

# Labels and Selectors

Labels provide a way to identify and group Kubernetes resources meaningfully.

They are key-value pairs, and they can be attached to many Kubernetes objects, such as:

- Pods
- Nodes
- Services
- Deployments
- ReplicaSets

Most Kubernetes objects can have labels attached to them.

Labels provide metadata that help identify and organize objects.

When creating a Pod, we often define labels under `metadata`.

These labels can then be leveraged by other Kubernetes resources, for example by a Service that wants to send traffic only to specific Pods.

Labels allow us to categorize and organize resources, and they enable sophisticated grouping and selection mechanisms.

This means we can build quite advanced selection logic when needed.

## Labels Are Not Unique

Unlike `metadata.name`, labels do not need to be unique.

Resource names need to be unique within a namespace.

Labels do not.

For example, two different Pods can both have:

```yaml
app: color-api
```

That is perfectly valid.

## What Selectors Are

Selectors are expressions used to filter Kubernetes objects based on labels.

Selectors allow users and Kubernetes components to target objects that match specific criteria.

For example, if we are interested only in Pods that belong to the `color-api` app, we can filter for Pods whose `app` label is `color-api`.

There are two main types of selectors in Kubernetes:

- equality-based selectors
- set-based selectors

## Equality-Based Selectors

Equality-based selectors are the older selector style, but they are still valid and still useful.

They match objects that have specific label key-value pairs.

We can specify one label or multiple labels.

Example:

```yaml
selector:
  matchLabels:
    app: color-api
    tier: backend
```

This selector matches Pods where:

- `app=color-api`
- `tier=backend`

That would match backend Pods of the `color-api` app, regardless of whether they are stable or canary.

## Set-Based Selectors

Set-based selectors are more flexible.

They allow us to match resources based on whether a label key belongs to a set of values.

Supported operators include:

- `In`
- `NotIn`
- `Exists`
- `DoesNotExist`

Example:

```yaml
selector:
  matchExpressions:
    - key: tier
      operator: In
      values:
        - frontend
        - backend
```

This matches Pods whose `tier` is either `frontend` or `backend`.

Another example:

```yaml
selector:
  matchExpressions:
    - key: release
      operator: NotIn
      values:
        - canary
```

This excludes Pods whose `release` is `canary`.

This can be especially helpful when there are many possible values and we want to exclude only one or two rather than list every allowed value.

## Practical Example with Two Pods

The notes then move into practice by creating a `color-api.yaml` file containing two Pods:

- a color backend Pod
- a color frontend Pod

Example backend Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: color-backend
  labels:
    app: color-api
    environment: local
    tier: backend
spec:
  containers:
    - name: color-backend
      image: lmacademy/color-api:1.1.0
      ports:
        - containerPort: 80
```

Example frontend Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: color-frontend
  labels:
    app: color-api
    environment: local
    tier: frontend
spec:
  containers:
    - name: color-frontend
      image: nginx:1.27.0
      ports:
        - containerPort: 80
```

## Using `kubectl` with Labels

Useful patterns shown in the notes:

Display label columns:

```bash
kubectl get pods -L app
kubectl get pods -L app -L tier
```

Filter with equality-based selection:

```bash
kubectl get pods -l app=color-api
kubectl get pods -l tier=frontend
kubectl get pods -l 'app=color-api,tier=frontend'
```

Filter with set-based selection:

```bash
kubectl get pods -l 'tier in (frontend)'
kubectl get pods -l 'tier notin (frontend)'
```

This becomes very useful once there are many Pods running in the cluster.

## Labels and Selectors in Deployments

The notes then build a Deployment and revisit selectors in the context of Deployment management.

Example shape:

```yaml
spec:
  selector:
    matchLabels:
      app: color-api
      environment: local
      tier: backend
  template:
    metadata:
      labels:
        app: color-api
        environment: local
        tier: backend
```

The key idea is:

- `selector.matchLabels` defines which Pods belong to the Deployment
- `template.metadata.labels` defines which labels new Pods created by the Deployment will have

The notes also explore `matchExpressions`.

One example introduces a `managed` label so that a Deployment can avoid overlapping with a standalone Pod that otherwise has identical labels.

That is a useful teaching point:

- overlapping selectors can become dangerous
- a Deployment should not accidentally match resources it is not supposed to manage

The notes recommend keeping Deployment selectors simple and avoiding overly broad or complex matching rules.

---

# Annotations

Annotations are also key-value pairs attached to Kubernetes objects.

They look similar to labels, but they serve a different purpose.

Unlike labels, annotations are not meant for identifying or selecting resources.

Instead, they are commonly used for:

- tool-specific metadata
- configuration
- build information
- version details
- commit hashes
- runtime hints for controllers and operators

One example from the notes is using annotations to configure an NGINX Ingress.

Even without understanding the full Ingress setup, the point is clear:

- annotations can change the behavior of a resource
- external controllers often read annotations to apply configuration

## Annotation Structure

Annotations can have a prefix that looks like a DNS subdomain.

Example shape:

```text
example.com/some-key
```

The prefix is commonly used by automated systems and third-party tools.

If the prefix is omitted, the annotation is assumed to be private or user-defined.

The notes emphasize that automated systems are expected to use proper prefixed keys.

---

# Namespaces

Namespaces provide a way to logically isolate resources within the same Kubernetes cluster.

They help divide cluster resources between:

- multiple users
- multiple teams
- multiple applications
- multiple environments

The notes use the analogy of a big house without rooms.

Without namespaces, everything lives together in one shared space.

That creates risk.

If one application suddenly consumes too much CPU or memory, it may affect unrelated applications, including critical ones.

Namespaces help create logical boundaries inside a shared cluster.

## Default Kubernetes Namespaces

Kubernetes normally ships with these built-in namespaces:

- `default`
- `kube-system`
- `kube-public`
- `kube-node-lease`

Very briefly:

- `default` is where resources go if no namespace is specified
- `kube-system` is used for Kubernetes system components
- `kube-public` is intended for publicly readable cluster information
- `kube-node-lease` helps manage node lease information used by kubelet health reporting

## Common Use Cases for Namespaces

- separating `dev`, `staging`, and `prod`
- isolating teams in multi-tenant clusters
- applying different quotas
- applying different RBAC permissions

The notes strongly connect namespaces with:

- resource quotas
- access control
- environment separation

## Creating a Namespace

Example:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

Namespaces are Kubernetes objects, so they can be created declaratively with YAML or imperatively with `kubectl`.

## Using Namespaces with `kubectl`

Get all namespaces:

```bash
kubectl get namespaces
```

Query resources in a namespace:

```bash
kubectl get pods -n dev
kubectl describe pod color-api -n dev
```

Set the current namespace in the current context:

```bash
kubectl config set-context --current --namespace=dev
```

This is convenient, but the notes also give an important warning:

- changing context is powerful
- forgetting which namespace you are in can be dangerous
- destructive commands in the wrong namespace can cause serious incidents

To inspect context:

```bash
kubectl config view
kubectl config current-context
```

## Deleting a Namespace

The notes highlight a critical behavior:

- deleting a namespace deletes the resources inside it

That means if a Pod exists inside `dev` and `dev` is deleted, the Pod is deleted too.

This is why namespace deletion should be treated as a sensitive operation.

## Listing Across All Namespaces

Another useful pattern:

```bash
kubectl get pods -A
```

This can help locate a Pod when you know the name but not the namespace.

---

# Communicating Across Namespaces

The notes then show how a Pod in one namespace can talk to a Service in another namespace.

Inside the same namespace, a Pod can often use just the Service name.

Across namespaces, the Pod must use the fully qualified domain name of the Service.

Example format:

```text
service-name.namespace.svc.cluster.local
```

So if a Service named `color-api` exists in namespace `dev`, the FQDN would be:

```text
color-api.dev.svc.cluster.local
```

This is useful for shared services such as:

- monitoring systems
- central internal tools
- cross-namespace integrations

The notes demonstrate this using:

- a `color-api` Pod in `dev`
- a Service exposing it in `dev`
- a traffic-generator Pod in the default namespace

The traffic generator uses the fully qualified service name to send requests successfully.

---

# Resource Quotas, Requests, and Limits

This is one of the main sections you specifically called out.

The notes explain these as two sides of the same coin.

## Resource Quotas

Resource quotas are namespace-level policies.

They define hard limits on how much of certain resources can be consumed by all objects inside a namespace.

Examples include:

- CPU
- memory
- storage
- object counts such as number of Pods

## Requests and Limits

Requests and limits are defined at the container level inside Pods.

They define how much resource a container needs or can use.

Requests represent the minimum resources a container should have available after scheduling.

Limits represent the maximum resources a container is allowed to use.

If a Pod has multiple containers, each container should define its own values.

## Example Quota

Example shape from the notes:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

And a larger `prod` quota might double those values.

The important idea is:

- quotas apply at the namespace level
- requests and limits apply at the container level

## Scheduling Logic

The notes walk through how multiple Pods consume quota cumulatively.

For example:

- Pod 1 requests some CPU and memory
- Pod 2 also requests some CPU and memory
- Kubernetes adds these together
- if Pod 3 would push total requested resources above quota, Pod 3 cannot be scheduled

The same logic applies to limits.

If the namespace quota would be exceeded, the Pod remains pending or creation is rejected.

## Example Pod Resource Settings

Example container resources:

```yaml
resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

The notes also explain `m` for CPU:

- `1000m` means 1 CPU core
- `500m` means half a core

## Important Practical Note

If quotas are enforced in a namespace, Pods should specify requests and limits.

Otherwise, Kubernetes may not behave as expected or may reject Pod creation depending on policy.

## Creating Namespaces with Quotas

The notes recommend creating the namespace and the resource quota together.

This is a very reasonable pattern.

In practice, a namespace without quota can become risky in shared clusters.

## Observing Quotas

Useful commands:

```bash
kubectl get resourcequota -A
kubectl describe resourcequota dev-quota -n dev
```

This helps compare:

- hard limit
- current usage

## When a Pod Exceeds Quota

The notes create a heavy Pod whose requests exceed the remaining namespace quota.

Result:

- `kubectl apply` fails
- Kubernetes returns a server-side `forbidden` error
- the error message explains that quota was exceeded

This is a very common and very real operational issue.

## Rollouts Can Also Get Stuck Because of Quota

One especially useful lesson in the notes is that a Deployment rollout can fail even if the current replicas fit inside quota.

Why?

Because rolling updates temporarily create additional Pods.

If the namespace is already near quota, the new Pods for the rollout may not be schedulable.

That means:

- rollout starts
- old Pods still exist
- new Pods try to come up
- quota is exceeded
- rollout gets stuck

The notes show how this becomes visible more clearly at the ReplicaSet level.

Useful commands:

```bash
kubectl rollout status deployment/color-api-deployment -n dev
kubectl get rs -n dev
kubectl describe rs <replicaset-name> -n dev
```

## Ways to Resolve Quota Problems

The notes mention several practical options:

- delete unused resources
- reduce requests and limits to better match real needs
- increase the namespace quota if hardware allows it
- restart the rollout after fixing quota

This is a great section because it shows the operational side, not just the YAML.

---

# Liveness, Readiness, and Startup Probes

The final major section of the notes covers health probes.

These are periodic health checks performed by Kubernetes.

They help Kubernetes decide:

- whether a container started successfully
- whether a container is still healthy
- whether a container is ready to receive traffic

## Startup Probe

The startup probe checks whether the application started successfully.

If it fails enough times, Kubernetes restarts the container.

This is particularly useful for applications with slow startup times.

## Liveness Probe

The liveness probe runs continuously while the container is alive.

It checks whether the container is still healthy.

If it fails enough times, Kubernetes restarts the container.

This is useful for deadlocks, stuck processes, or applications that are technically running but no longer functioning correctly.

## Readiness Probe

The readiness probe also runs continuously.

But instead of restarting the container, it decides whether the container should receive traffic.

If the readiness probe fails:

- the container stays running
- the Pod is removed from Service endpoints
- traffic is not sent to it

This is extremely important for avoiding broken or half-initialized Pods serving requests.

## Probe Behavior Summary

- startup probe failure leads to restart
- liveness probe failure leads to restart
- readiness probe failure removes the Pod from traffic

## Extending the Demo App

The notes then extend the `color-api` application with:

- environment variables
- probe-specific endpoints
- behavior that intentionally fails probes

Example environment variables:

- `DELAY_STARTUP`
- `FAIL_LIVENESS`
- `FAIL_READINESS`

And example endpoints:

- `/up` for startup probe
- `/health` for liveness probe
- `/ready` for readiness probe

This is a smart demo design because it lets one image simulate multiple health scenarios.

## Startup Probe Example

Example shape:

```yaml
startupProbe:
  httpGet:
    path: /up
    port: 80
  failureThreshold: 2
  periodSeconds: 3
```

With delayed startup enabled, the startup probe fails, the container restarts repeatedly, and eventually enters `CrashLoopBackOff`.

Useful commands:

```bash
kubectl get pod
kubectl describe pod color-api-pod
```

## Liveness Probe Example

Example shape:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 80
  failureThreshold: 3
  periodSeconds: 10
```

With `FAIL_LIVENESS=true`, the application starts successfully but later fails health checks.

Kubernetes restarts the container on a recurring basis.

## Readiness Probe Example

Example shape:

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 80
  failureThreshold: 2
  periodSeconds: 5
```

The notes then create:

- a Deployment with multiple replicas
- a Service
- a traffic-generator Pod

Some Pods randomly fail readiness.

As a result:

- unhealthy Pods remain running
- unhealthy Pods do not receive traffic
- only ready Pods are included in Service endpoints

This is one of the best practical demonstrations in the notes.

Useful commands:

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs traffic-generator -f
kubectl describe service color-api-svc
kubectl get pods -o wide
```

The Service endpoint list clearly shows that only healthy Pods are receiving traffic.

---

# Big Takeaways

This full note set teaches several important Kubernetes habits:

- use labels consistently
- keep selectors clear and non-overlapping
- use annotations for metadata and tool configuration
- use namespaces for logical isolation
- use fully qualified Service names across namespaces
- define requests and limits at the container level
- protect namespaces with resource quotas
- remember that rollouts and scaling can be blocked by quota
- always use probes so Kubernetes can react automatically to unhealthy containers

## Short Memory Aids

Labels:

- identify and group resources

Selectors:

- find resources by label

Annotations:

- attach non-identifying metadata or config

Namespaces:

- isolate resources logically inside the same cluster

ResourceQuota:

- caps what a namespace can consume

Requests:

- minimum needed for scheduling

Limits:

- maximum allowed usage

Startup probe:

- did the app start?

Liveness probe:

- is the app still healthy?

Readiness probe:

- should this Pod receive traffic right now?

---

# Practical Reference Commands

```bash
kubectl get pods
kubectl get pods -A
kubectl get pods -L app -L tier
kubectl get pods -l app=color-api
kubectl get pods -l 'app=color-api,tier=frontend'
kubectl get namespaces
kubectl get resourcequota -A
kubectl describe resourcequota dev-quota -n dev
kubectl rollout status deployment/color-api-deployment -n dev
kubectl get rs -n dev
kubectl describe rs <replicaset-name> -n dev
kubectl describe service color-api-svc
kubectl config set-context --current --namespace=dev
kubectl config view
```
