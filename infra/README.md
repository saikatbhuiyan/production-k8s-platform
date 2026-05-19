# Kubernetes Notes for This `infra/` Folder

This folder contains examples for:

- labels and selectors
- Deployments
- standalone Pods
- namespaces
- resource quotas

## Files in This Folder

- `3labels-selectors/`: basic examples of labels and selectors
- `4resource-quotas/`: examples with namespaces, quotas, Pods, and Deployments

## Pod vs Deployment

### Standalone Pod

File: [4resource-quotas/color-api.-pod.yml](/Users/saikat/Documents/Projects/v2/Projects/backend/k8s-expess-app/infra/4resource-quotas/color-api.-pod.yml:1)

A Pod manifest creates one Pod directly.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: color-api
  namespace: dev
  labels:
    app: color-api
```

This creates a single Pod named `color-api`.

Use a standalone Pod when:

- learning Kubernetes basics
- testing a container quickly
- creating a simple example

### Deployment

File: [4resource-quotas/color-api-depl.yml](/Users/saikat/Documents/Projects/v2/Projects/backend/k8s-expess-app/infra/4resource-quotas/color-api-depl.yml:1)

A Deployment manages Pods for you.

Example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: color-api-depl
  namespace: dev
spec:
  replicas: 4
  selector:
    matchLabels:
      app: color-api
  template:
    metadata:
      labels:
        app: color-api
```

This means:

- create 4 replicas
- give each Pod the label `app: color-api`
- manage Pods with the label `app: color-api`

Use a Deployment when:

- you want multiple replicas
- you want self-healing if a Pod dies
- you want rolling updates
- you want normal app-style Kubernetes management

In most real apps, we use a Deployment instead of creating Pods manually.

## How `selector.matchLabels` Works

In your Deployment:

```yaml
selector:
  matchLabels:
    app: color-api
```

This tells Kubernetes:

"This Deployment manages Pods that have the label `app: color-api`."

In the Pod template of the same Deployment:

```yaml
template:
  metadata:
    labels:
      app: color-api
```

This tells Kubernetes:

"When creating new Pods, add the label `app: color-api`."

These two should match.

Short version:

- `selector` = which Pods belong to me?
- `template.labels` = label new Pods like this

## Does the Deployment Selector Match the Standalone Pod?

Yes.

Your standalone Pod also has:

```yaml
labels:
  app: color-api
```

So it matches this selector:

```yaml
matchLabels:
  app: color-api
```

That is why this command shows both the standalone Pod and the Deployment-created Pods:

```bash
kubectl get pods -n dev -l app=color-api
```

Important note:

- matching labels does not mean the standalone Pod was created by the Deployment
- the Deployment only controls Pods created through its own ReplicaSet
- but using the same labels across separate resources can be confusing when listing Pods

## Deployment Flow

```text
Deployment
  -> ReplicaSet
      -> Pods
```

What each part does:

- Deployment: desired state, updates, rollout
- ReplicaSet: keeps the requested number of Pods running
- Pod: runs the container

## Why You Saw Running Pods but `0/4` on the Deployment

You had:

- an older Deployment named `color-api`
- a standalone Pod named `color-api`
- a new Deployment named `color-api-depl`

The older resources were already using namespace quota.

Your new Deployment wanted 4 more Pods, but Kubernetes blocked them because the `dev` namespace quota was already full.

That is why:

- `kubectl get pods -n dev -l app=color-api` showed running Pods
- `kubectl get deployment color-api-depl -n dev` showed `0/4`

The running Pods belonged to older resources, not to the new Deployment.

## Resource Quota in This Example

The `dev` namespace has a ResourceQuota.

A ResourceQuota limits how much a namespace can use, for example:

- CPU limits
- memory limits
- memory requests

Your `color-api-depl` Pods request:

- `cpu: 200m`
- `memory: 256Mi`
- `limits.cpu: 500m`
- `limits.memory: 512Mi`

If the namespace quota is already fully used, new Pods cannot be created.

## Useful Commands

Check Deployments:

```bash
kubectl get deploy -n dev
```

Check one Deployment:

```bash
kubectl get deployment color-api-depl -n dev
```

Check Pods with a label:

```bash
kubectl get pods -n dev -l app=color-api
```

See labels too:

```bash
kubectl get pods -n dev -l app=color-api --show-labels
```

See why a Deployment is not creating Pods:

```bash
kubectl describe deployment color-api-depl -n dev
kubectl describe rs -n dev
```

Check quota:

```bash
kubectl describe quota -n dev
```

## Best Practice for This Example

To avoid confusion:

- use a Deployment for the app
- avoid keeping a standalone Pod with the same app label unless you need it for learning
- make sure `selector.matchLabels` and `template.metadata.labels` match
- check namespace quota before increasing replicas

## Simple Rule to Remember

- Pod manifest: creates one Pod directly
- Deployment manifest: creates and manages Pods for you
- `selector.matchLabels`: finds matching Pods
- `template.metadata.labels`: labels the Pods the Deployment creates
- ResourceQuota can stop new Pods even when the YAML is correct
