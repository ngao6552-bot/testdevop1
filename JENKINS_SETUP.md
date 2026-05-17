# Jenkins CI/CD Pipeline - Hướng Dẫn Cấu Hình

## 📋 Yêu Cầu

- Jenkins 2.361+
- Node.js 18+
- Docker & Docker Compose
- Git
- Plugin Jenkins:
  - Pipeline
  - NodeJS Plugin
  - Docker Pipeline
  - GitHub Plugin (tùy chọn)
  - Email Extension (tùy chọn)
  - Slack Notification (tùy chọn)

## 🚀 Cài Đặt Nhanh

### 1. Cài Đặt Jenkins Plugins

```bash
# Truy cập Jenkins > Manage Jenkins > Manage Plugins > Available
# Tìm và cài đặt:
- Pipeline
- NodeJS Plugin  
- Docker Pipeline
- GitHub Integration
- Email Extension
```

### 2. Cấu Hình NodeJS Tool

```
Jenkins > Manage Jenkins > Tools > NodeJS installations
- Name: NodeJS
- Version: 18.x
- Automatic Installer: Check
```

### 3. Tạo Pipeline Job

```
New Item > Pipeline > Enter name > OK

Pipeline section:
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: <your-repo-url>
- Branch: */main
- Script Path: Jenkinsfile
```

### 4. Cấu Hình Credentials (Tùy Chọn)

```
Jenkins > Manage Jenkins > Credentials > System > Global credentials

- GitHub Token
- Docker Hub Credentials
- Deploy Server SSH Key
```

## 📝 Các Stage trong Pipeline

| Stage | Mô Tả |
|-------|--------|
| **Checkout** | Clone code từ repository |
| **Install Dependencies** | Cài đặt npm packages cho Backend & Frontend |
| **Build Backend** | Compile Backend code |
| **Build Frontend** | Tạo Frontend production build |
| **Unit Tests** | Chạy các unit tests |
| **Code Quality** | Lint code |
| **Archive Artifacts** | Lưu trữ build output |
| **Deploy Staging** | Deploy lên staging (khi merge vào main) |
| **Deploy Production** | Deploy lên production (manual approval) |

## 🐳 Docker Deployment

### Build và Push Image

```bash
cd /path/to/project
docker build -t myregistry/devops-app:latest .
docker push myregistry/devops-app:latest
```

### Deploy với Docker Compose

```bash
docker-compose up -d
```

### Kiểm tra Status

```bash
docker ps
docker logs <container-name>
```

## 🔍 Monitoring & Logs

### View Console Output

```
Jenkins > Build History > Select Build > Console Output
```

### Docker Logs

```bash
docker logs -f backend
docker logs -f frontend
```

### Health Check

```bash
curl http://localhost:5000/health
curl http://localhost/health
```

## ⚙️ Environment Variables

Đặt các biến environment trong Jenkins:

```
NODE_ENV=production
VITE_API_URL=https://api.yourdomain.com
DB_URL=mongodb://...
JWT_SECRET=your-secret-key
```

## 🔔 Notifications

### Email Notification

```groovy
post {
    failure {
        emailext(
            subject: 'Build Failed: ${PROJECT_NAME}',
            body: 'Build failed. Check console output at ${BUILD_URL}',
            to: 'team@example.com'
        )
    }
}
```

### Slack Notification

```groovy
post {
    always {
        slackSend(
            channel: '#ci-cd',
            message: "Build ${BUILD_NUMBER}: ${currentBuild.result}",
            tokenCredentialId: 'slack-token'
        )
    }
}
```

## 🛠️ Troubleshooting

### Issue: "nodejs not found"
```
→ Kiểm tra NodeJS Plugin được cài chưa
→ Đảm bảo NodeJS Tool được cấu hình trong Manage Tools
```

### Issue: "npm: command not found"
```
→ Thêm npm vào PATH: ${NODEJS_HOME}/bin:${PATH}
```

### Issue: "Port already in use"
```
→ Kiểm tra các container đang chạy: docker ps
→ Stop container: docker stop <container-id>
```

### Issue: Build timeout
```
→ Tăng timeout trong Jenkinsfile
→ Kiểm tra dependencies installation time
```

## 📚 Tài Liệu Tham Khảo

- [Jenkins Pipeline Documentation](https://jenkins.io/doc/book/pipeline/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js in Docker](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

## ✅ Checklist Deployment

- [ ] Jenkins configured với NodeJS Plugin
- [ ] Git repository được connect
- [ ] Jenkinsfile được commit vào repo
- [ ] Environment variables được set
- [ ] Docker credentials được cấu hình
- [ ] Health check endpoints hoạt động
- [ ] Test local trước: `docker-compose up -d`
- [ ] Check logs: `docker-compose logs -f`
