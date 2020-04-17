# build image with $SHA tag
docker build -t masashiu/multi-client:latest -t masashiu/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t masashiu/multi-server:latest -t masashiu/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t masashiu/multi-worker:latest -t masashiu/multi-worker:$SHA -f ./worker/Dockerfile ./worker

# Log in to the docker CLI
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin

# Take those images and push them to docker hub
# tag = latest
docker push masashiu/multi-client:latest
docker push masashiu/multi-server:latest
docker push masashiu/multi-worker:latest
# tag = $SHA
docker push masashiu/multi-client:$SHA
docker push masashiu/multi-server:$SHA
docker push masashiu/multi-worker:$SHA

# eks configure
aws eks --region ap-northeast-1 update-kubeconfig --name uemura-udemy-cluster
# kuebctl apply changes
kubectl apply -f k8s
kubectl set image deployments/server-deployment server=masashiu/multi-server:$SHA
kubectl set image deployments/client-deployment client=masashiu/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=masashiu/multi-worker:$SHA
