#3. Java Web Application on Kubernetes

This project deploys a Java web application to a Kubernetes cluster using a `Deployment`, `Service`, and `Ingress`. The application is containerized and accessible via a custom domain (`java-app.example.com`) through an NGINX Ingress controller.

## Prerequisites

- **Minikube**: A local Kubernetes cluster (or any Kubernetes cluster).
- **kubectl**: Kubernetes command-line tool.
- **Docker**: To build and push the container image (assumed already done as `hadeeralaa542/java-web-app:v1`).
- **NGINX Ingress Controller**: Installed in the cluster.

## Structure

```
k8s/
├── deployment.yaml    # Defines the Java app deployment
├── service.yaml       # Exposes the app within the cluster
└── ingress.yaml       # Routes external traffic to the app
```

## Deployment Steps

### 1. Start Minikube
Ensure Minikube is running:
```bash
minikube start
```

### 2. Enable NGINX Ingress Controller
Enable the Ingress addon in Minikube:
```bash
minikube addons enable ingress
```
Verify it’s running:
```bash
kubectl get pods -n ingress-nginx
```
<img width="407" alt="image" src="https://github.com/user-attachments/assets/502eede2-ae9b-4111-84f3-4666edc35e68" />

### 3. Create the Namespace
Create the `ivolve-namespace`:
```bash
kubectl create namespace ivolve-namespace
```
Verify:
```bash
kubectl get namespaces
```
<img width="323" alt="image" src="https://github.com/user-attachments/assets/6c3dbc04-2077-4359-8aed-b25b15bc9cc8" />

### 4. Deploy the Application
Apply the deployment:
```bash
kubectl apply -f k8s/deployment.yaml
```
Check the pods:
```bash
kubectl get pods -n ivolve-namespace
```
<img width="392" alt="image" src="https://github.com/user-attachments/assets/fc49580e-8f86-460a-94cc-5c72c63e5eb8" />

### 5. Expose the Application with a Service
Apply the service (uses `ClusterIP` for internal access):
```bash
kubectl apply -f k8s/service.yaml
```
Verify:
```bash
kubectl get svc -n ivolve-namespace
```
<img width="412" alt="image" src="https://github.com/user-attachments/assets/ad755093-5cab-4026-8c9a-4b0690ef5556" />

### 6. Configure Ingress
Apply the Ingress resource to route external traffic:
```bash
kubectl apply -f k8s/ingress.yaml
```
Check the Ingress:
```bash
kubectl get ingress -n ivolve-namespace
```
<img width="411" alt="image" src="https://github.com/user-attachments/assets/0bfbcfee-2f24-44c9-a38b-6de6a209722d" />

### 7. Update Hosts File
Get the Minikube IP:
```bash
minikube ip
```
Edit `/etc/hosts` to map `java-app.example.com` to the Minikube IP:
```bash
sudo nano /etc/hosts
```
Add:
```
<minikube-ip> java-app.example.com
```
Example:
```
192.168.49.2 java-app.example.com
```

### 8. Test the Application
Test with `curl`:
```bash
curl http://java-app.example.com
```
<img width="440" alt="image" src="https://github.com/user-attachments/assets/8c33a20e-56c0-44cd-a2c6-ca46b87ea53f" />

Or open in a browser:
```
http://java-app.example.com
```
<img width="429" alt="image" src="https://github.com/user-attachments/assets/6534998d-37cb-415d-8e58-6b89f81957dd" />

## Kubernetes Manifests

### `deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app
  namespace: ivolve-namespace
spec:
  replicas: 2
  selector:
    matchLabels:
      app: java-app
  template:
    metadata:
      labels:
        app: java-app
    spec:
      containers:
        - name: java-app
          image: hadeeralaa542/java-web-app:v1
          ports:
            - containerPort: 8081
```

### `service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: java-app-service
  namespace: ivolve-namespace
spec:
  selector:
    app: java-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8081
  type: ClusterIP
```

### `ingress.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: java-app-ingress
  namespace: ivolve-namespace
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: java-app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: java-app-service
                port:
                  number: 80
```

## Troubleshooting

- **Pods Not Running**: Check logs:
  ```bash
  kubectl logs <pod-name> -n ivolve-namespace
  ```
- **Ingress Not Working**: Ensure the NGINX controller is running and `/etc/hosts` is updated:
  ```bash
  kubectl get pods -n ingress-nginx
  ```
- **curl Fails**: Verify DNS resolution:
  ```bash
  ping java-app.example.com
  ```
- **Service Connectivity**: Test internally:
  ```bash
  kubectl port-forward svc/java-app-service -n ivolve-namespace 8081:80
  curl http://localhost:8081
  ```
