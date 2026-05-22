echo -n 'username' | base64

echo -n 'password' | base64


kubectl apply -f mongo-secret.yml

kubectl get all | grep mongo
