Login into linod

Go to Kubernetes Cluster

Create Cluster for worker node

Download the yaml file 

Update to only you can read from the file with this command 

chmod 400 example.yaml

set the file as a kubeconfig

export KUBECONFIG=example.yaml

kubectl get nodes  -> can see lind worker nodes
