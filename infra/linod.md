Login into linod

Go to Kubernetes Cluster

Create Cluster for worker node

Download the yaml file 

Update to only you can read from the file with this command 

chmod 400 example.yaml

set the file as a kubeconfig

export KUBECONFIG=example.yaml

kubectl get nodes  -> can see lind worker nodes


brew install helm

helm version

helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm search repo nginx

helm list
kubectl get pods

helm repo add
helm repo update
helm search repo

helm create
helm install
helm upgrade
helm rollback
helm uninstall

helm template
helm lint

helm install mongodb bitnami/mongodb

helm install [our name] --values [values file name] [chart name]

helm install mongodb --values helm-mongodb.yaml bitnami/mongodb
