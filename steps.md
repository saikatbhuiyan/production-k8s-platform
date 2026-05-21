## Steps we followed

First, we create a simple express app and Dockerize it.

```sh
docker build -t express-api:latest .
docker run -p 8080:8080 express-api:latest
```

Second, we push the image to docker hub.

```sh
docker login
docker tag express-api:latest 01919965532/express-api:1.0.0
docker push 01919965532/express-api:1.0.0
```

kubectl run express-api --image=01919965532/express-api:1.0.0 --port=8080
kubectl expose pod express-api --port=80 --target-port=8080
kubectl get pods
kubectl get svc
