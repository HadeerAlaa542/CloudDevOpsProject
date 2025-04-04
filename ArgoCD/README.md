# Deploying a Java App on EKS with ArgoCD 

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
