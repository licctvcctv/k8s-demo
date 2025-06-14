# GitHub上传指南

## 📋 准备上传的文件列表

### K8s配置文件
- `namespace.yaml` - 命名空间配置
- `service-discovery.yaml` - Eureka服务发现
- `cloud-config.yaml` - 配置中心
- `api-gateway.yaml` - API网关
- `user-service.yaml` - 用户服务
- `business-services.yaml` - 业务微服务
- `monitoring.yaml` - 监控服务(Zipkin)
- `simple-deploy.yaml` - 简化部署配置

### 部署脚本
- `deploy.sh` - 完整部署脚本
- `simple-deploy.sh` - 简化部署脚本
- `cleanup.sh` - 清理脚本
- `validate.sh` - 验证脚本

### 配置文件
- `values.yaml` - Helm配置
- `README.md` - 部署文档

## 🚀 上传步骤

### 1. 克隆仓库
```bash
git clone https://github.com/licctvcctv/k8s-demo.git
cd k8s-demo
```

### 2. 创建新分支
```bash
git checkout -b ecommerce-microservices
```

### 3. 创建项目目录
```bash
mkdir -p ecommerce-microservices/k8s
```

### 4. 复制文件
将以下文件复制到 `ecommerce-microservices/k8s/` 目录：
- 所有 .yaml 文件
- 所有 .sh 脚本
- README.md

### 5. 提交代码
```bash
git add .
git commit -m "Add ecommerce microservices k8s deployment configs

- Complete Spring Cloud microservices deployment
- Includes Eureka, Config Server, API Gateway
- User service and business services (product, order, payment, shipping)
- Monitoring with Zipkin
- Both full and simplified deployment options"

git push origin ecommerce-microservices
```

### 6. 创建Pull Request
在GitHub上创建从 `ecommerce-microservices` 到 `main` 的Pull Request

## 📁 最终目录结构
```
k8s-demo/
└── ecommerce-microservices/
    ├── README.md
    └── k8s/
        ├── namespace.yaml
        ├── service-discovery.yaml
        ├── cloud-config.yaml
        ├── api-gateway.yaml
        ├── user-service.yaml
        ├── business-services.yaml
        ├── monitoring.yaml
        ├── simple-deploy.yaml
        ├── deploy.sh
        ├── simple-deploy.sh
        ├── cleanup.sh
        ├── validate.sh
        ├── values.yaml
        └── README.md
```
