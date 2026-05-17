# 🚀 Jenkins CI/CD Pipeline - DevOps Project

> Jenkins Pipeline CI/CD được tối ưu cho MERN Stack application (Student Management System)

## 📁 Cấu Trúc File CI/CD

```
DevOps-main/
├── Jenkinsfile                    # Pipeline chính
├── Dockerfile                     # Build image cho Backend
├── docker-compose.yml             # Orchestration services
├── .env.example                   # Environment variables mẫu
├── JENKINS_SETUP.md              # Hướng dẫn cấu hình Jenkins
├── nginx-jenkins.conf            # Nginx config cho Jenkins proxy
│
├── Backend/
│   ├── package.json              # Scripts: start, dev, build, test, lint
│   ├── server.js
│   ├── Dockerfile.frontend       # Frontend container
│   ├── nginx.conf                # Nginx config cho Frontend
│   └── models/, routes/
│
├── Frontend/
│   ├── package.json              # React + Vite config
│   ├── vite.config.js
│   ├── src/
│   └── public/
│
└── scripts/
    ├── deploy.sh                 # Deployment script
    └── health-check.sh           # Health monitoring
```

## 🎯 Quick Start

### 1️⃣ Chuẩn Bị Môi Trường

```bash
# Clone repository
git clone <your-repo-url>
cd DevOps-main

# Copy env file
cp .env.example .env
# Edit .env với các giá trị của bạn
```

### 2️⃣ Cài Đặt Jenkins

#### Trên Linux/Mac:
```bash
# Cài Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Run Jenkins
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts-jdk11
```

#### Trên Windows:
```powershell
# Cài Docker Desktop
# Sau đó chạy:
docker run -d -p 8080:8080 -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  jenkins/jenkins:lts-jdk11
```

### 3️⃣ Cấu Hình Jenkins

1. **Truy cập Jenkins**: http://localhost:8080
2. **Lấy mật khẩu ban đầu**:
   ```bash
   docker exec <jenkins-container-id> cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. **Cài Plugins**:
   - Pipeline
   - NodeJS Plugin
   - Docker Pipeline
   - GitHub Integration

4. **Tạo Job mới**:
   - Name: `DevOps-CI-CD`
   - Type: `Pipeline`
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `<your-repo-url>`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

### 4️⃣ Test Local Trước

```bash
# Build images
docker build -t devops-app:latest .

# Run with docker-compose
docker-compose up -d

# Kiểm tra status
docker ps
docker-compose logs -f

# Health check
curl http://localhost:5000/health
curl http://localhost/health
```

## 📊 Pipeline Workflow

```
┌─────────────────────────────────────────────────────┐
│ GitHub Push / Manual Trigger                        │
└──────────────────┬──────────────────────────────────┘
                   │
         ┌─────────▼─────────┐
         │  Checkout Code    │
         └────────┬──────────┘
                  │
    ┌─────────────┴─────────────┐
    │                           │
┌───▼──────────────────┐   ┌────▼──────────────────┐
│ Backend Install      │   │ Frontend Install     │
│ Backend Build        │   │ Frontend Build       │
└────┬────────────────┘    └────┬──────────────────┘
     │                          │
     └──────────┬───────────────┘
                │
        ┌───────▼────────┐
        │ Run Tests      │
        └───────┬────────┘
                │
        ┌───────▼────────┐
        │ Code Quality   │
        └───────┬────────┘
                │
        ┌───────▼────────┐
        │ Archive Artifacts
        └───────┬────────┘
                │
         ┌──────▼──────────┐
         │ Deploy Staging  │
         │ (main branch)   │
         └──────┬──────────┘
                │
         ┌──────▼──────────┐
         │ Manual Approval │
         └──────┬──────────┘
                │
         ┌──────▼──────────┐
         │ Deploy Production
         │ (tagged release)
         └─────────────────┘
```

## 🔑 Environment Variables

### Backend (.env)
```bash
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb://mongo:27017/student_management
JWT_SECRET=your-secret-key
```

### Frontend (.env)
```bash
VITE_API_URL=http://localhost:5000
```

## 🐳 Docker Commands

```bash
# Build image
docker build -t devops-app:latest .

# Build với tag
docker build -t myregistry/devops-app:v1.0 .

# Run container
docker run -d -p 5000:5000 devops-app:latest

# Push to registry
docker push myregistry/devops-app:latest

# Docker Compose
docker-compose up -d
docker-compose down
docker-compose logs -f
docker-compose ps
```

## 🚀 Deployment Options

### Option 1: Docker Compose (Local/Dev)
```bash
docker-compose up -d
```

### Option 2: Kubernetes
```yaml
# Deploy với kubectl
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl get pods
```

### Option 3: Vercel (Frontend)
```bash
# Deploy Frontend to Vercel
npm install -g vercel
vercel
```

## 📈 Monitoring & Logging

### View Jenkins Logs
```
Jenkins > Build History > Select Build > Console Output
```

### Docker Logs
```bash
docker logs -f <container-name>
docker-compose logs -f
```

### Health Check
```bash
# Backend
curl http://localhost:5000/health

# Frontend
curl http://localhost/health
```

## 🔐 Security Best Practices

1. **Credentials Management**
   - Không commit `.env` file
   - Sử dụng Jenkins Credentials
   - Rotate secrets regularly

2. **Docker Security**
   - Sử dụng non-root user
   - Update base images
   - Scan images với Trivy

3. **CI/CD Pipeline**
   - Enable branch protection
   - Require PR reviews
   - Automated testing required

## 🛠️ Troubleshooting

### Issue: Build timeout
```bash
# Tăng timeout trong Jenkinsfile
timeout(time: 2, unit: 'HOURS')
```

### Issue: Port already in use
```bash
docker ps
docker stop <container-id>
docker rm <container-id>
```

### Issue: NodeJS not found
```
Jenkins > Manage Jenkins > Tools > NodeJS installations
# Cấu hình NodeJS 18.x với automatic installer
```

### Issue: Permission denied in deploy.sh
```bash
chmod +x scripts/deploy.sh
chmod +x scripts/health-check.sh
```

## 📚 Jenkins Plugins Cần Thiết

| Plugin | Mục Đích |
|--------|----------|
| Pipeline | Declarative & Scripted Pipeline |
| NodeJS Plugin | Node.js environment |
| Docker Pipeline | Docker integration |
| GitHub Integration | Auto trigger từ GitHub |
| Email Extension | Email notifications |
| Slack Notification | Slack alerts |
| Artifactory | Artifact management |

## ✅ Deployment Checklist

- [ ] Jenkins cài đặt và chạy
- [ ] Plugins installed
- [ ] Git repository connected
- [ ] Environment variables configured
- [ ] Docker credentials set up
- [ ] Jenkinsfile in repo root
- [ ] Local test passed
- [ ] Health checks configured
- [ ] Monitoring set up
- [ ] Backup strategy in place

## 📞 Support & Documentation

- [Jenkins Documentation](https://jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Alternative](https://github.com/features/actions)
- [GitLab CI/CD Alternative](https://docs.gitlab.com/ee/ci/)

## 📄 License

ISC

---

**Created**: 2024
**Last Updated**: May 2026
**Status**: Production Ready ✅
