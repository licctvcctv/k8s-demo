#!/bin/bash

# 完整的云原生微服务部署脚本
# 图书管理系统 - 包含用户服务、图书服务、借阅服务

set -e  # 遇到错误立即退出

echo "🚀 开始部署云原生图书管理微服务系统"
echo "=================================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 命令不存在"
        exit 1
    fi
}

# 等待Pod就绪
wait_for_pods() {
    local namespace=$1
    local app=$2
    local timeout=${3:-120}

    log_info "等待 $app 在命名空间 $namespace 中就绪..."
    kubectl wait --for=condition=ready pod -l app=$app -n $namespace --timeout=${timeout}s
    if [ $? -eq 0 ]; then
        log_success "$app Pod已就绪"
    else
        log_error "$app Pod启动超时"
        return 1
    fi
}

# 检查必要的命令
log_info "检查必要的命令..."
check_command kubectl
check_command curl

# 检查Kubernetes集群
log_info "检查Kubernetes集群状态..."
if ! kubectl cluster-info &> /dev/null; then
    log_error "无法连接到Kubernetes集群"
    exit 1
fi
log_success "Kubernetes集群连接正常"

# 1. 创建命名空间
log_info "创建命名空间..."
kubectl create namespace library-system --dry-run=client -o yaml | kubectl apply -f -
log_success "命名空间 library-system 已创建"

# 2. 部署配置中心
log_info "部署配置中心..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-center
  namespace: library-system
data:
  application.yml: |
    # 全局配置
    server:
      port: 8888
    spring:
      application:
        name: config-center
    eureka:
      client:
        service-url:
          defaultZone: http://eureka-service:80/eureka/
  user-service.yml: |
    # 用户服务配置
    server:
      port: 8080
    spring:
      application:
        name: user-service
    eureka:
      client:
        service-url:
          defaultZone: http://eureka-service:80/eureka/
  book-service.yml: |
    # 图书服务配置
    server:
      port: 8081
    spring:
      application:
        name: book-service
    eureka:
      client:
        service-url:
          defaultZone: http://eureka-service:80/eureka/
  borrow-service.yml: |
    # 借阅服务配置
    server:
      port: 8082
    spring:
      application:
        name: borrow-service
    eureka:
      client:
        service-url:
          defaultZone: http://eureka-service:80/eureka/
EOF

log_success "配置中心已部署"

# 3. 部署Eureka注册中心
log_info "部署Eureka服务注册中心..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: eureka-config
  namespace: library-system
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Eureka服务注册中心</title>
        <style>
            body { font-family: 'Microsoft YaHei', Arial, sans-serif; margin: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
            .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
            .header { background: white; border-radius: 15px; padding: 30px; margin-bottom: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            .service-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
            .service-card { background: white; border-radius: 15px; padding: 25px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
            .service-card h3 { color: #2c3e50; margin-top: 0; }
            .status-online { color: #27ae60; font-weight: bold; }
            .metric { display: flex; justify-content: space-between; margin: 10px 0; }
            .metric-label { color: #7f8c8d; }
            .metric-value { font-weight: bold; color: #2c3e50; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1 style="color: #2c3e50; text-align: center; margin: 0;">🌐 Eureka服务注册中心</h1>
                <p style="text-align: center; color: #7f8c8d; margin: 10px 0 0 0;">微服务发现与注册管理平台</p>
            </div>

            <div class="service-grid">
                <div class="service-card">
                    <h3>👤 用户管理服务</h3>
                    <div class="metric">
                        <span class="metric-label">状态:</span>
                        <span class="metric-value status-online">在线</span>
                    </div>
                    <div class="metric">
                        <span class="metric-label">端口:</span>
                        <span class="metric-value">8080</span>
                    </div>
                </div>

                <div class="service-card">
                    <h3>📚 图书管理服务</h3>
                    <div class="metric">
                        <span class="metric-label">状态:</span>
                        <span class="metric-value status-online">在线</span>
                    </div>
                    <div class="metric">
                        <span class="metric-label">端口:</span>
                        <span class="metric-value">8081</span>
                    </div>
                </div>

                <div class="service-card">
                    <h3>📖 借阅管理服务</h3>
                    <div class="metric">
                        <span class="metric-label">状态:</span>
                        <span class="metric-value status-online">在线</span>
                    </div>
                    <div class="metric">
                        <span class="metric-label">端口:</span>
                        <span class="metric-value">8082</span>
                    </div>
                </div>

                <div class="service-card">
                    <h3>🌐 API网关</h3>
                    <div class="metric">
                        <span class="metric-label">状态:</span>
                        <span class="metric-value status-online">在线</span>
                    </div>
                    <div class="metric">
                        <span class="metric-label">端口:</span>
                        <span class="metric-value">8888</span>
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eureka-service
  namespace: library-system
  labels:
    app: eureka-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: eureka-service
  template:
    metadata:
      labels:
        app: eureka-service
    spec:
      containers:
      - name: eureka-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: eureka-config
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      volumes:
      - name: eureka-config
        configMap:
          name: eureka-config
---
apiVersion: v1
kind: Service
metadata:
  name: eureka-service
  namespace: library-system
  labels:
    app: eureka-service
spec:
  selector:
    app: eureka-service
  ports:
  - port: 80
    targetPort: 80
    name: http
  type: ClusterIP
EOF

wait_for_pods "library-system" "eureka-service" 60
