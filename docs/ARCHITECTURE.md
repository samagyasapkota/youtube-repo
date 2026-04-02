# DevOps Project Architecture Documentation

## Project Overview
YouTube Clone App deployed with full DevOps pipeline on VirtualBox VMs.

## Infrastructure

### Virtual Machines
| VM | IP | Role | Specs |
|---|---|---|---|
| jenkins-app | 192.168.56.10 | CI/CD Server | 2 CPU, 2GB RAM |
| k8s-node | 192.168.56.20 | Kubernetes Cluster | 2 CPU, 5GB RAM |
| monitoring | 192.168.56.30 | Monitoring Stack | 2 CPU, 2GB RAM |

## Architecture Diagram
```
GitHub Repo (samagyasapkota/youtube-repo)
         |
         | (webhook/manual trigger)
         ▼
Jenkins CI/CD (192.168.56.10:8080)
    |          |
    |          ├── npm install
    |          ├── npm run build  
    |          ├── docker build
    |          └── docker push → DockerHub
         |
         ▼
DockerHub (samagyasapkota/youtube-app)
         |
         ▼
Kubernetes Cluster (192.168.56.20)
    |
    ├── 5-10 Pods (HPA)
    ├── NodePort Service (:30090)
    └── youtube-app accessible at 192.168.56.20:30090

Monitoring Stack (192.168.56.30)
    ├── Prometheus (:9090)
    │     ├── Scrapes jenkins-app:9100
    │     ├── Scrapes k8s-node:9100
    │     └── Scrapes monitoring:9100
    └── Grafana (:3000)
          └── Node Exporter Dashboard (ID: 1860)
```

## Tech Stack
- **Source Control**: GitHub
- **CI/CD**: Jenkins
- **Containerization**: Docker
- **Container Registry**: DockerHub
- **Orchestration**: Kubernetes (kubeadm)
- **IaC**: Vagrant + VirtualBox
- **Config Management**: Ansible
- **Monitoring**: Prometheus + Grafana + Node Exporter
- **Web Server**: Nginx (inside container)
- **App**: React.js YouTube Clone

## CI/CD Pipeline Stages
1. Git Checkout (staging branch)
2. Install Dependencies (npm install)
3. Build Application (npm run build)
4. Docker Build (build image)
5. Docker Push (push to DockerHub)
6. Deploy to Staging (docker-compose)

## Kubernetes Setup
- **Cluster**: Single node (kubeadm)
- **Network**: Calico CNI
- **Replicas**: 5 (min) - 10 (max)
- **Autoscaling**: HPA based on CPU 70%
- **Service Type**: NodePort (30090)

## Monitoring Setup
- **Prometheus**: Collects metrics from all 3 VMs
- **Node Exporter**: Installed on all VMs
- **Grafana**: Dashboard ID 1860 (Node Exporter Full)
- **Alerts**: CPU > 80%, RAM > 80%

## Backup Strategy
- **Schedule**: Daily at 10PM (cron: 0 22 * * *)
- **Backup Location**: /opt/backups/
- **Retention**: 7 days
- **Script**: /home/vagrant/youtube-repo/scripts/backup.sh

## Access Points
| Service | URL |
|---|---|
| Application | http://192.168.56.20:30090 |
| Jenkins | http://192.168.56.10:8080 |
| Prometheus | http://192.168.56.30:9090 |
| Grafana | http://192.168.56.30:3000 |
