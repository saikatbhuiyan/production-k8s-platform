# Volumes and Persistent Storage

Volumes bring many of the persistence concepts we already know from Docker into Kubernetes.

As you already know, what we run in Kubernetes are containers.

Containers, by definition, do not provide persistent storage by themselves.

Any time we need either of the following:

- persistent data
- shared data between containers

we should start thinking about volumes.

## What a Volume Is

From the container's perspective, a volume is basically just a directory.

That directory may already contain data, and the container can interact with it like a normal filesystem path.

The important part is that different volume types differ in:

- how the directory is created
- what backs the directory
- what data appears in it
- how long the data survives

In other words, a volume always looks like a directory to the container, but the storage medium behind that directory can vary a lot.

## What Backs a Volume

Kubernetes supports many possible storage backends.

Examples include:

- AWS EBS
- AWS EFS
- GCP storage backends
- Azure storage backends
- local SSDs
- node-local directories

This is what leads to the different types of volumes we use in Kubernetes.

---

# Where Volumes Are Declared

To use a volume in Kubernetes, we define it in the Pod specification and then mount it into one or more containers.

The two important places are:

- `spec.volumes`
- `spec.containers[].volumeMounts`

The basic rule is:

- declare the volume at the Pod level
- mount that volume into the container where it should appear

Example structure:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  volumes:
    - name: shared-data
      emptyDir: {}

  containers:
    - name: app
      image: nginx
      volumeMounts:
        - name: shared-data
          mountPath: /data
```

Important detail:

- the name used under `volumeMounts.name` must match the name used under `spec.volumes`

## Volume Dependencies

Some volumes must already exist before a Pod can use them.

Examples:

- PersistentVolumes
- PersistentVolumeClaims
- ConfigMaps
- Secrets

As long as the storage resource exists, the Pod can reference it and mount it.

---

# Pod-Level View of Volumes

The notes describe a useful mental picture:

- a cluster contains nodes
- a node runs a Pod
- the Pod defines one or more volumes
- containers inside the Pod mount those volumes

From that point on, the container only sees a filesystem path.

The backing storage, however, may be:

- temporary Pod storage
- node-local storage
- configuration data
- cloud-backed persistent storage

This is why the same mount pattern can support many very different use cases.

---

# Common Volume Types

The original notes focus on a few common volume types that are especially important for beginners.

## `emptyDir`

`emptyDir` is used for ephemeral storage within a Pod.

It is useful for:

- scratch files
- temporary data
- sharing files between containers in the same Pod

Its lifecycle is tied to the Pod.

That means:

- it is created when the Pod starts
- it survives container restarts within the same Pod
- it is deleted when the Pod is removed

This makes it a good fit for temporary storage, but not for important long-term data.

## Local Node Storage

The notes then discuss storage that exists on the node itself.

This kind of storage is different from `emptyDir` because it can outlive the Pod.

However, it is still tied to the specific node where the data lives.

That means:

- if the node fails, the data may be unavailable
- if the Pod is scheduled onto another node, it may not see the same data

This is an important limitation of node-local storage.

## `hostPath`

The notes mention `hostPath` as an older and common storage type.

`hostPath` mounts a directory from the node filesystem directly into the Pod.

It is often discouraged because it may introduce:

- security risks
- strong coupling to the node
- portability problems

You may still see it in:

- older codebases
- demos
- local development setups

But it is generally not the preferred choice for normal application storage in production.

## `local`

The notes recommend `local` as the safer and more structured alternative to `hostPath`.

`local` storage creates durable storage on a specific node and is treated as a PersistentVolume-backed solution.

That means:

- it requires a PersistentVolume definition
- it requires a PersistentVolumeClaim
- it often requires node affinity

### Why Node Affinity Matters

Because the storage physically exists on one specific node, workloads using it must be scheduled in a way that respects that location.

Without that, a Pod could land on the wrong node and fail to access the expected data.

So the key tradeoff of `local` storage is:

- it is more durable than Pod-local storage
- but it is still tied to one node

---

# Persistent Volumes in General

The notes then broaden the discussion to PersistentVolumes more generally.

PersistentVolumes can be backed by many technologies, including:

- local storage
- cloud block storage
- cloud file storage
- other external storage systems

This is one of the most important ideas in Kubernetes storage:

- the Pod should not need to care about the exact storage system
- Kubernetes provides an abstraction for consuming the storage

## PersistentVolume and PersistentVolumeClaim

When working with persistent storage, the common model is:

- create or provision storage
- expose it as a PersistentVolume (`PV`)
- request it through a PersistentVolumeClaim (`PVC`)
- mount the claim into the Pod

In simplified form:

```
storage backend -> PV -> PVC -> Pod
```

The notes stress that these resources usually need to exist before the Pod can consume them.

---

# Static and Dynamic Provisioning

One especially important part of the notes is the distinction between static and dynamic provisioning.

## Static Provisioning

With static provisioning:

- the PersistentVolume is created first
- then a claim is created to use it

This is more manual and requires the storage resource to be prepared in advance.

## Dynamic Provisioning

With dynamic provisioning:

- the PersistentVolumeClaim is created first
- Kubernetes provisions matching storage automatically
- the resulting PersistentVolume is created to satisfy the claim

This is the more cloud-native and scalable approach in many environments.

A StorageClass is usually involved in this flow, even though the source notes do not go deep into it yet.

---

# ConfigMap and Secret Volumes

The original notes also point out that not all volumes are used for application data.

Some are used to inject information into the container filesystem.

## ConfigMap Volumes

ConfigMaps can be mounted as volumes.

This allows Pods to receive configuration data without hardcoding it directly into the Pod definition or container image.

This is useful for things like:

- application settings
- config files
- feature flags
- non-sensitive environment-specific values

## Secret Volumes

Secrets can also be mounted as volumes.

This allows containers to access sensitive data through files.

Typical examples include:

- passwords
- tokens
- keys
- certificates

The notes correctly emphasize an important practice:

- secret values should not be hardcoded into repository files

Even when using Secrets, we still need to think carefully about how the secret data is created, loaded, and protected.

---

# Third-Party and Cloud Storage Backends

The notes mention third-party and cloud-backed storage options such as:

- AWS EBS
- AWS EFS

The same idea also extends to storage solutions from GCP, Azure, and many vendors.

Kubernetes can mount these backends into Pods through the storage abstractions it provides.

This means a workload can use:

- block storage for database files
- shared file storage for multi-instance access
- vendor-managed storage for more advanced enterprise needs

---

# CSI Drivers

The notes briefly point toward CSI drivers as the next deeper topic.

CSI stands for Container Storage Interface.

This is the standard mechanism Kubernetes uses to integrate with storage systems.

If someone wants to:

- support a custom storage backend
- understand how storage plugins work
- go deeper into Kubernetes storage internals

then CSI is a very important area to study.

---

# Practical Interpretation of the Main Storage Types

Here is a cleaner summary of the main storage options discussed in the notes.

## Use `emptyDir` When

- the data is temporary
- the data only needs to live as long as the Pod
- multiple containers in the same Pod need shared scratch space

## Use `local` Storage When

- the data must survive Pod recreation
- the storage can stay tied to one node
- you understand the scheduling implications

## Be Careful with `hostPath`

- it may be useful for experiments or certain infrastructure components
- it is usually discouraged for normal production application storage

## Use Persistent Volumes When

- the data must survive Pod replacement
- the workload is stateful
- the storage backend may be cloud or external

## Use ConfigMap or Secret Volumes When

- you need to inject configuration or sensitive data as files

---

# Common Kubernetes Storage Themes

Reading across the notes, a few core themes appear repeatedly.

## 1. Containers Are Ephemeral

Kubernetes assumes Pods and containers may be recreated at any time.

If the data is important, it should not live only inside the writable container filesystem.

## 2. The Pod Sees a Directory, Not the Whole Storage Story

To the container, a volume is just a mounted directory.

But operationally, that directory might represent:

- temporary memory-backed space
- local disk
- cloud block storage
- network file storage
- generated config files

## 3. Storage Choice Changes Failure Behavior

Different volume types behave differently during:

- Pod deletion
- container restart
- node failure
- rescheduling

Choosing the wrong storage type often causes subtle failures later.

## 4. Kubernetes Storage Is Mostly About Abstraction

The Pod does not need to know all the implementation details.

Instead, Kubernetes gives us abstractions such as:

- Volumes
- PersistentVolumes
- PersistentVolumeClaims
- CSI integrations

---

# Common Mistakes

Based on the notes, these are the main mistakes beginners should watch for.

## Storing Important Data in a Temporary Volume

If the data matters after the Pod is gone, `emptyDir` is not the right choice.

## Assuming Node-Local Data Follows the Pod Everywhere

Node-local data stays on that node.

If the Pod moves, the data may not follow.

## Overusing `hostPath`

It may look simple, but it often creates security and portability problems.

## Forgetting That Some Volume Resources Must Exist First

If a Pod references a missing PVC, ConfigMap, or Secret, the workload will not behave as expected.

## Ignoring Scheduling Constraints for Local Storage

If storage is physically tied to one node, the Pod placement rules must reflect that.

---

# Minimal Example Pattern

The source notes do not fully build a complete manifest example for every type, but the common mounting pattern is clear:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-demo
spec:
  volumes:
    - name: app-storage
      persistentVolumeClaim:
        claimName: app-pvc

  containers:
    - name: app
      image: nginx
      volumeMounts:
        - name: app-storage
          mountPath: /data
```

This shows the main idea:

- the Pod defines a volume
- the volume uses a PVC
- the container mounts that volume at a filesystem path

---

# Final Summary

The storage notes teach the following big ideas:

- volumes are how Kubernetes handles persistence and shared filesystem access
- from the container view, a volume is just a directory
- the storage backend behind that directory can vary widely
- `emptyDir` is temporary and Pod-scoped
- `hostPath` is common but generally discouraged
- `local` storage is more structured but still node-bound
- PersistentVolumes and PersistentVolumeClaims provide general persistent storage
- persistent storage can be provisioned statically or dynamically
- ConfigMaps and Secrets can also be mounted as volumes
- CSI drivers are the deeper extension point for storage systems

Together, these concepts form the foundation of Kubernetes storage and persistence.
