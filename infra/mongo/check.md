kubectl exec -it mongo-ss-0 -- mongosh -u `<root-username>` -p `<root-password>` --authenticationDatabase admin

use colordb
db.getUsers()


##scale

kubectl scale statefulset mongo-ss --replicas=3

verify

kubectl get pods -l app=mongo
