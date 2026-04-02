# DevOps Project - Complete Documentation
## YouTube Clone App Deployment

---

## Table of Contents
1. Project Overview
2. Infrastructure Setup
3. Application Setup
4. CI/CD Pipeline
5. Containerization
6. Kubernetes Deployment
7. Monitoring Setup
8. Backup Strategy
9. Architecture Diagram
10. Access Points

---

## 1. Project Overview

| Item | Detail |
|---|---|
| Application | YouTube Clone (React.js) |
| Source Repo | github.com/Aj7Ay/Youtube-clone-app |
| Own Repo | github.com/samagyasapkota/youtube-repo |
| Branch | staging |
| Infrastructure | VirtualBox + Vagrant |

---

## 2. Infrastructure Setup

### Virtual Machines
| VM Name | IP Address | Role | RAM | CPU |
|---|---|---|---|---|
| jenkins-app | 192.168.56.10 | CI/CD + Docker | 2GB | 2 |
| k8s-node | 192.168.56.20 | Kubernetes | 5GB | 2 |
| monitoring | 192.168.56.30 | Prometheus+Grafana | 2GB | 2 |

### Vagrant Setup
- Provider: VirtualBox
- OS: Ubuntu 22.04 (jammy64)
- Network: Host-Only Adapter (192.168.56.x)
- Vagrantfile location: C:/devops-project/spring-devops-cicd-project

### Tools Installed Per VM

**jenkins-app:**
- Jenkins
- Docker
- Node.js 20
- Git
- Node Exporter

**k8s-node:**
- kubeadm v1.28
- kubectl
- kubelet
- Calico CNI
- Node Exporter

**monitoring:**
- Prometheus v2.48.0
- Grafana v12.4.2
- Node Exporter v1.7.0

---

## 3. Application Setup

### Tech Stack
- Frontend: React.js
- API: RapidAPI (YouTube Data)
- Build Tool: Create React App
- Web Server: Nginx (in container)

### Repository Structure
```
youtube-repo/
├── src/                    # React source code
├── public/                 # Static files
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yml      # Deployment + Service + HPA
│   └── hpa.yml            # Horizontal Pod Autoscaler
├── ansible/               # Ansible playbooks
│   ├── inventory.ini      # VM inventory
│   └── playbook.yml       # Setup playbook
├── scripts/               # Utility scripts
│   └── backup.sh          # Backup script
├── docs/                  # Documentation
├── Dockerfile             # Docker build file
├── docker-compose.yml     # Docker compose
├── Jenkinsfile            # CI/CD pipeline
├── nginx.conf             # Nginx config
├── package.json           # Node dependencies
└── .env                   # Environment variables
```

---

## 4. CI/CD Pipeline (Jenkins)

### Pipeline Stages
```
Stage 1: Git Checkout
    └── Clones staging branch from GitHub

Stage 2: Install Dependencies  
    └── npm install

Stage 3: Build Application
    └── CI=false npm run build

Stage 4: Docker Build
    └── docker build -t samagyasapkota/youtube-app:BUILD_NUMBER

Stage 5: Docker Push
    └── Push to DockerHub (samagyasapkota/youtube-app)

Stage 6: Deploy to Staging
    └── docker-compose up -d
```

### Jenkins Configuration
- URL: http://192.168.56.10:8080
- Pipeline: youtube-pipeline
- SCM: GitHub
- Branch: staging
- Trigger: Manual / Git webhook

### DockerHub
- Repository: samagyasapkota/youtube-app
- Tags: latest + build number

---

## 5. Containerization

### Dockerfile
- Base image: node:16
- Build: npm run build
- Serve: npm start
- Port: 3000

### Docker Compose
- Service: youtube-app
- Port mapping: 3000:3000
- Network: youtube-network
- Restart: always

---

## 6. Kubernetes Deployment

### Cluster Info
| Item | Detail |
|---|---|
| Setup tool | kubeadm |
| Version | v1.28.15 |
| Node | k8s-node (192.168.56.20) |
| CNI | Calico |
| Node IP | 192.168.56.20 |

### Deployment
| Item | Detail |
|---|---|
| Replicas | 5 (min) - 10 (max) |
| Image | samagyasapkota/youtube-app:latest |
| Container Port | 3000 |
| CPU Request | 100m |
| CPU Limit | 300m |
| Memory Request | 256Mi |
| Memory Limit | 512Mi |

### Service
| Item | Detail |
|---|---|
| Type | NodePort |
| Port | 3000 |
| NodePort | 30090 |
| Access URL | http://192.168.56.20:30090 |

### HPA (Horizontal Pod Autoscaler)
| Item | Detail |
|---|---|
| Min Pods | 5 |
| Max Pods | 10 |
| CPU Threshold | 70% |
| Scale Up | When CPU > 70% |
| Scale Down | When CPU < 70% |

### Useful kubectl Commands
```bash
# Check pods
kubectl get pods

# Check service
kubectl get svc

# Check HPA
kubectl get hpa

# Scale manually
kubectl scale deployment youtube-app --replicas=10

# View logs
kubectl logs -f <pod-name>

# Describe pod
kubectl describe pod <pod-name>
```

---

## 7. Monitoring Setup

### Prometheus
- URL: http://192.168.56.30:9090
- Version: 2.48.0
- Scrape Interval: 15s
- Config: /etc/prometheus/prometheus.yml

### Scrape Targets
| Target | IP | Port | Status |
|---|---|---|---|
| jenkins-app | 192.168.56.10 | 9100 | UP |
| k8s-node | 192.168.56.20 | 9100 | UP |
| monitoring | 192.168.56.30 | 9100 | UP |

### Alert Rules
| Alert | Condition | Severity |
|---|---|---|
| HighCPUUsage | CPU > 80% for 2min | Warning |
| CriticalCPUUsage | CPU > 95% for 1min | Critical |
| HighMemoryUsage | RAM > 80% for 2min | Warning |
| CriticalMemoryUsage | RAM > 95% for 1min | Critical |

### Grafana
- URL: http://192.168.56.30:3000
- Version: 12.4.2
- Default Login: admin/admin
- Dashboard: Node Exporter Full (ID: 1860)
- Data Source: Prometheus

### Node Exporter
- Version: 1.7.0
- Port: 9100
- Installed on: All 3 VMs
- Metrics: CPU, RAM, Disk, Network

---

## 8. Backup Strategy

### Cronjob Schedule
```
0 22 * * * /home/vagrant/youtube-repo/scripts/backup.sh
```
Runs every day at 10:00 PM

### Backup Script
- Location: /home/vagrant/youtube-repo/scripts/backup.sh
- Backup Dir: /opt/backups/
- Retention: 7 days
- Log: /var/log/backup.log

### What Gets Backed Up
- Application source code
- Configuration files
- Environment files

### Note on Database
This application (YouTube Clone React) has no backend
database. It uses RapidAPI to fetch YouTube data directly.
Therefore only application backup cronjob is configured
as per task instructions.

---

## 9. Architecture Diagram
```
┌─────────────────────────────────────────────────┐
│                  DEVELOPER                       │
│              (Windows + MobaXterm)               │
└──────────────────┬──────────────────────────────┘
                   │ git push
                   ▼
┌─────────────────────────────────────────────────┐
│              GITHUB                              │
│    samagyasapkota/youtube-repo (staging)         │
└──────────────────┬──────────────────────────────┘
                   │ trigger
                   ▼
┌─────────────────────────────────────────────────┐
│         jenkins-app (192.168.56.10)              │
│                                                  │
│  ┌─────────┐  ┌──────┐  ┌────────┐  ┌───────┐  │
│  │ Jenkins │→ │ npm  │→ │Docker  │→ │Docker │  │
│  │ :8080   │  │build │  │ build  │  │ push  │  │
│  └─────────┘  └──────┘  └────────┘  └───┬───┘  │
│                                          │       │
│  Node Exporter :9100                     │       │
└──────────────────────────────────────────┼───────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────┐
│              DOCKERHUB                           │
│         samagyasapkota/youtube-app               │
└──────────────────┬──────────────────────────────┘
                   │ pull
                   ▼
┌─────────────────────────────────────────────────┐
│           k8s-node (192.168.56.20)               │
│                                                  │
│  ┌─────────────────────────────────────────┐    │
│  │         Kubernetes Cluster               │    │
│  │                                          │    │
│  │  ┌──────┐┌──────┐┌──────┐┌──────┐┌────┐│    │
│  │  │ Pod  ││ Pod  ││ Pod  ││ Pod  ││Pod ││    │
│  │  │  1   ││  2   ││  3   ││  4   ││ 5  ││    │
│  │  └──────┘└──────┘└──────┘└──────┘└────┘│    │
│  │                                          │    │
│  │  HPA: 5-10 pods | NodePort: 30090        │    │
│  └─────────────────────────────────────────┘    │
│                                                  │
│  Node Exporter :9100                             │
└──────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│          monitoring (192.168.56.30)              │
│                                                  │
│  ┌────────────┐      ┌─────────────┐            │
│  │ Prometheus │      │   Grafana   │            │
│  │   :9090    │─────▶│    :3000    │            │
│  └─────┬──────┘      └─────────────┘            │
│        │                                         │
│        │ scrapes :9100                           │
│        ├──▶ jenkins-app                          │
│        ├──▶ k8s-node                             │
│        └──▶ monitoring                           │
│                                                  │
│  Node Exporter :9100                             │
└──────────────────────────────────────────────────┘
```

---

## 10. Access Points Summary

| Service | URL | Credentials |
|---|---|---|
| YouTube App | http://192.168.56.20:30090 | None |
| Jenkins | http://192.168.56.10:8080 | admin/admin123 |
| Prometheus | http://192.168.56.30:9090 | None |
| Grafana | http://192.168.56.30:3000 | admin/admin |
| DockerHub | hub.docker.com/r/samagyasapkota/youtube-app | - |
| GitHub | github.com/samagyasapkota/youtube-repo | - |

---

## Troubleshooting

### Jenkins not accessible
```bash
sudo systemctl restart jenkins
sudo systemctl status jenkins
```

### Pods not running
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Prometheus targets down
```bash
sudo systemctl status node_exporter
sudo systemctl restart node_exporter
```

### App not accessible
```bash
kubectl get svc
kubectl get pods
curl http://192.168.56.20:30090
```

---
*Documentation created: March 2026*
*Author: samagyasapkota*
