# E-Commerce微服务Kubernetes部署指南

## 📋 概述

本目录包含将E-Commerce微服务应用部署到Kubernetes集群的所有配置文件和脚本。

## 🏗️ 架构组件

### 基础设施服务
- **service-discovery** (Eureka) - 服务注册与发现
- **cloud-config** - 配置中心
- **api-gateway** - API网关
- **zipkin** - 分布式追踪

### 业务微服务
- **user-service** - 用户管理和认证
- **product-service** - 商品管理
- **order-service** - 订单管理
- **payment-service** - 支付处理
- **shipping-service** - 物流配送

## 🚀 快速部署

### 前置条件
1. Kubernetes集群 (v1.20+)
2. kubectl已配置并连接到集群
3. 集群有足够资源 (建议至少4GB内存，2CPU)

### 一键部署
```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

### 手动部署
```bash
# 1. 创建命名空间
kubectl apply -f namespace.yaml

# 2. 部署基础设施服务
kubectl apply -f service-discovery.yaml
kubectl apply -f cloud-config.yaml
kubectl apply -f api-gateway.yaml

# 3. 部署业务服务
kubectl apply -f user-service.yaml
kubectl apply -f business-services.yaml

# 4. 部署监控服务
kubectl apply -f monitoring.yaml
```

## 🔍 验证部署

### 检查Pod状态
```bash
kubectl get pods -n ecommerce-microservices
```

### 检查服务状态
```bash
kubectl get services -n ecommerce-microservices
```

### 查看日志
```bash
kubectl logs -f deployment/api-gateway -n ecommerce-microservices
```

## 🌐 访问服务

### 端口转发
```bash
# Eureka服务发现
kubectl port-forward -n ecommerce-microservices svc/service-discovery-service 8761:8761

# API网关
kubectl port-forward -n ecommerce-microservices svc/api-gateway-service 8080:8080

# Zipkin追踪
kubectl port-forward -n ecommerce-microservices svc/zipkin-service 9411:9411
```

### 访问地址
- Eureka: http://localhost:8761
- API网关: http://localhost:8080
- Zipkin: http://localhost:9411

## 📊 监控和日志

### 查看所有Pod状态
```bash
kubectl get pods -n ecommerce-microservices -w
```

### 查看特定服务日志
```bash
kubectl logs -f deployment/user-service -n ecommerce-microservices
```

### 查看服务健康状态
```bash
kubectl get endpoints -n ecommerce-microservices
```

## 🗑️ 清理部署

### 一键清理
```bash
chmod +x cleanup.sh
./cleanup.sh
```

### 手动清理
```bash
kubectl delete namespace ecommerce-microservices
```

## ⚙️ 配置说明

### 资源配置
每个服务的资源配置：
- **requests**: memory: 512Mi, cpu: 250m
- **limits**: memory: 1Gi, cpu: 500m

### 副本配置
- 基础设施服务: 1个副本
- 业务服务: 2个副本 (高可用)

### 健康检查
所有服务都配置了：
- **livenessProbe**: 存活性探针
- **readinessProbe**: 就绪性探针

## 🔧 故障排除

### 常见问题

1. **Pod启动失败**
   ```bash
   kubectl describe pod <pod-name> -n ecommerce-microservices
   ```

2. **服务无法访问**
   ```bash
   kubectl get endpoints -n ecommerce-microservices
   ```

3. **镜像拉取失败**
   - 检查镜像名称和标签
   - 确保网络连接正常

### 调试命令
```bash
# 进入Pod调试
kubectl exec -it <pod-name> -n ecommerce-microservices -- /bin/bash

# 查看事件
kubectl get events -n ecommerce-microservices --sort-by='.lastTimestamp'
```

## 📝 注意事项

1. 确保Kubernetes集群有足够的资源
2. 服务启动有依赖顺序，建议按脚本顺序部署
3. 生产环境建议配置持久化存储
4. 建议配置Ingress Controller用于外部访问
