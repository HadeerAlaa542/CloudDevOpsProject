# 1. Java Web Application on Kubernetes

This project deploys a Java web application to a Kubernetes cluster using a `Deployment`, `Service`, and `Ingress`. The application is containerized and accessible via a custom domain (`java-app.example.com`) through an NGINX Ingress controller.

## Prerequisites

- **Minikube**: A local Kubernetes cluster (or any Kubernetes cluster).
- **kubectl**: Kubernetes command-line tool.
- **Docker**: To build and push the container image (assumed already done as `hadeeralaa542/java-web-app:v1`).
- **NGINX Ingress Controller**: Installed in the cluster.

## Structure

```
kubernetes /
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
---

# 2. Deploying a Java App on EKS with ArgoCD 

This guide outlines the steps to deploy a Java Spring Boot application on Amazon EKS using ArgoCD for GitOps and an NGINX Ingress Controller to expose it at `java-app.example.com`. The app (`hadeeralaa542/java-web-app:v1`) is served from a Kubernetes cluster and accessed locally via `/etc/hosts`.

## Prerequisites
- **AWS CLI**: Installed and configured (`aws configure`).
- **kubectl**: Installed for cluster management.
- **eksctl**: Installed to create the EKS cluster.
- **Helm**: Installed for NGINX Ingress Controller setup.
- **Git Repository**: Contains Kubernetes manifests (`Deployment`, `Service`, `Ingress`).
- Local machine with admin access (e.g., `sudo`).

## Steps

### 1. Create the EKS Cluster
- Install `eksctl` if missing:
  ```bash
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin/
  eksctl version
  ```
- Create the cluster:
  ```bash
  eksctl create cluster --name ivolve-eks --region us-east-1 --nodegroup-name workers --node-type t3.medium --nodes 2 --managed
  ```
  - Wait ~15-20 minutes for provisioning.
- Verify:
  ```bash
  kubectl get nodes
  ```
  - Expect 2 nodes with `Ready` status.

![image](https://github.com/user-attachments/assets/935ca356-2ea4-45c8-af8e-bc938c150f05)

### 2. Install ArgoCD
- Deploy ArgoCD:
  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```
- Verify:
  ```bash
  kubectl get pods -n argocd
  ```
  
- Access the UI (temporary):
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 4040:443
  ```
![image](https://github.com/user-attachments/assets/a69682b2-e73c-41ef-854c-e4f7c5eb0507)

  - Open `https://localhost:4040`.
  - Get password:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
  - Login: `admin` / `<password>`.
    
![image](https://github.com/user-attachments/assets/635c84cc-9ff9-4600-a93f-931fffb957d2)

### 3. Deploy the Java App via ArgoCD
- **Git Repository**: Contains:
  - `deployment.yaml`
  - `service.yaml`
  - `ingress.yaml`

- **Add Repo to ArgoCD**:
  - In the ArgoCD UI:
    - Go to **Settings > Repositories**.
    - Click **+ Connect Repo**.
    - URL: `<your-git-repo-url>` (e.g., `https://github.com/yourusername/your-repo.git`).
    - Add credentials if private (username/password or SSH key).
    - Click **Connect**.
![image](https://github.com/user-attachments/assets/3759c62e-4c4f-4901-94f6-d0f86af7e68b)
![image](https://github.com/user-attachments/assets/658569e8-5a34-4ff3-b433-6b19dd74cc95)

  - Create the app:
    - Go to **Applications > + New App**.
    - Name: `ivolve-app`.
    - Project: `default`.
    - Sync Policy: `Manual`.
    - Repository URL: `<your-git-repo-url>`.
    - Path: `.` (or folder with manifests).
    - Cluster: `https://kubernetes.default.svc`.
    - Namespace: `ivolve-namespace`.
    - Click **Create**.
  - Sync:
    - Open the app, click **Sync**, then **Synchronize**.

![image](https://github.com/user-attachments/assets/96e50d71-ea8e-4c67-bb7a-dc3183137027)

![image](https://github.com/user-attachments/assets/9c80e8e4-4c02-4cb6-8446-6150ee8b8c78)

![image](https://github.com/user-attachments/assets/f84168b0-9572-4992-8a83-45b5f0c3dc08)

- Verify:
  ```bash
  kubectl get pods -n ivolve-namespace
  ```
  - Expect 2 `java-app` pods running.

![image](https://github.com/user-attachments/assets/e9d56ee1-352a-46fa-a96f-e0ad0ff112cb)


### 4. Install NGINX Ingress Controller
- Install Helm:
  ```bash
  sudo snap install helm --classic
  helm version
  ```
- Deploy NGINX Ingress:
  ```bash
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
  ```
- Verify:
  ```bash
  kubectl get pods -n ingress-nginx
  ```
  - Look for `ingress-nginx-controller` pod running.

![image](https://github.com/user-attachments/assets/7a5c9e78-d0fd-40e2-bfd9-8aeece228efc)

- Get LoadBalancer hostname:
  ```bash
  kubectl get svc -n ingress-nginx
  ```
  - Note `EXTERNAL-IP` (e.g., `a233472a0bb0d4d4e99abb55303f07b4-2145554817.us-east-1.elb.amazonaws.com`).

### 5. Access the App Locally
- **Edit /etc/hosts**:
  ```bash
  sudo nano /etc/hosts
  ```
  - Add:
    ```
    54.146.70.36 java-app.example.com
    ```
    (Using an IP from the ELB’s resolution—`54.146.70.36` worked; alternatively, use the hostname: `a233472a0bb0d4d4e99abb55303f07b4-2145554817.us-east-1.elb.amazonaws.com`.)
  - Save and exit.
- **Test**:
  ```bash
  curl -v http://java-app.example.com
  ```
  - Expect `200` with:
    ```
    <h1>iVolve Technologies</h1>
    <h3>Hello, Spring Boot NTI</h3>
    <div>My Pod IP is : <span>...</span></div>
    ```
![image](https://github.com/user-attachments/assets/81df3f63-0927-4dcb-b358-373831bcfd42)
    
- **Browser**:
  - Open `http://java-app.example.com`.
  - See the app’s welcome page.

![image](https://github.com/user-attachments/assets/b17b04e2-7e25-4c89-b2c9-fbbb314d8494)

### 6. Troubleshooting
- **Resolution Issues**:
  - Verify `/etc/hosts`:
    ```bash
    cat /etc/hosts
    ping java-app.example.com
    ```
  - Test with IP:
    ```bash
    curl -v http://54.146.70.36 -H "Host: java-app.example.com"
    ```
- **404 from NGINX**:
  - Check `Ingress`:
    ```bash
    kubectl describe ingress java-app-ingress -n ivolve-namespace
    ```
  - Test `Service`:
    ```bash
    kubectl port-forward svc/java-app-service 8080:80 -n ivolve-namespace
    ```
    Open `http://localhost:8080`.
- **Pod Logs**:
  ```bash
  kubectl logs <pod-name> -n ivolve-namespace
  ```

## Final Result
- App deployed on EKS via ArgoCD.
- Accessible at `http://java-app.example.com` locally, routed through NGINX Ingress.
- Displays:
  ```
  iVolve Technologies
  Hello, Spring Boot NTI
  My Pod IP is: <pod-ip>
  ```

## Cleanup (Optional)
- Delete cluster:
  ```bash
  eksctl delete cluster --name ivolve-eks
  ```
  ---
