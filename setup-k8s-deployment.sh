#!/bin/bash

echo "🚀 为SpringCloud项目添加K8s部署支持"

cd sample-spring-microservices-new

# 1. 创建K8s部署目录
echo "📁 创建K8s部署目录..."
mkdir -p k8s
mkdir -p scripts

# 2. 重命名服务目录（符合图书管理系统）
echo "📚 重命名服务为图书管理系统..."
mv employee-service user-service
mv department-service book-service  
mv organization-service borrow-service
mv discovery-service eureka-service

# 3. 修改父pom.xml中的模块名称
echo "✏️ 修改pom.xml模块配置..."
sed -i 's/<module>employee-service<\/module>/<module>user-service<\/module>/g' pom.xml
sed -i 's/<module>department-service<\/module>/<module>book-service<\/module>/g' pom.xml
sed -i 's/<module>organization-service<\/module>/<module>borrow-service<\/module>/g' pom.xml
sed -i 's/<module>discovery-service<\/module>/<module>eureka-service<\/module>/g' pom.xml

# 4. 创建构建脚本（使用buildkit）
cat > scripts/build-images.sh << 'EOF'
#!/bin/bash

echo "🔨 使用buildkit构建镜像..."

# 构建各个服务的镜像
services=("config-service" "eureka-service" "user-service" "book-service" "borrow-service" "gateway-service")

for service in "${services[@]}"; do
    echo "构建 $service 镜像..."
    cd $service
    
    # 先打包jar
    mvn clean package -DskipTests
    
    # 使用buildkit构建镜像
    buildctl build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=library-system/$service:latest
    
    cd ..
done

echo "✅ 所有镜像构建完成！"
EOF

# 5. 创建K8s部署文件
cat > k8s/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: library-system
EOF

cat > k8s/config-service.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-service
  namespace: library-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: config-service
  template:
    metadata:
      labels:
        app: config-service
    spec:
      containers:
      - name: config-service
        image: library-system/config-service:latest
        ports:
        - containerPort: 8088
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "k8s"
---
apiVersion: v1
kind: Service
metadata:
  name: config-service
  namespace: library-system
spec:
  selector:
    app: config-service
  ports:
  - port: 8088
    targetPort: 8088
  type: ClusterIP
EOF

cat > k8s/eureka-service.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eureka-service
  namespace: library-system
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
        image: library-system/eureka-service:latest
        ports:
        - containerPort: 8061
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "k8s"
---
apiVersion: v1
kind: Service
metadata:
  name: eureka-service
  namespace: library-system
spec:
  selector:
    app: eureka-service
  ports:
  - port: 8061
    targetPort: 8061
  type: ClusterIP
EOF

cat > k8s/gateway-service.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gateway-service
  namespace: library-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gateway-service
  template:
    metadata:
      labels:
        app: gateway-service
    spec:
      containers:
      - name: gateway-service
        image: library-system/gateway-service:latest
        ports:
        - containerPort: 8060
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "k8s"
---
apiVersion: v1
kind: Service
metadata:
  name: gateway-service
  namespace: library-system
spec:
  selector:
    app: gateway-service
  ports:
  - port: 8060
    targetPort: 8060
    nodePort: 30999
  type: NodePort
EOF

# 6. 创建部署脚本
cat > scripts/deploy-k8s.sh << 'EOF'
#!/bin/bash

echo "🚀 部署到Kubernetes集群..."

# 创建命名空间
kubectl apply -f k8s/namespace.yaml

# 按顺序部署服务
echo "部署配置服务..."
kubectl apply -f k8s/config-service.yaml

echo "等待配置服务启动..."
kubectl wait --for=condition=ready pod -l app=config-service -n library-system --timeout=300s

echo "部署注册中心..."
kubectl apply -f k8s/eureka-service.yaml

echo "等待注册中心启动..."
kubectl wait --for=condition=ready pod -l app=eureka-service -n library-system --timeout=300s

echo "部署业务服务..."
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/book-service.yaml
kubectl apply -f k8s/borrow-service.yaml

echo "部署网关服务..."
kubectl apply -f k8s/gateway-service.yaml

echo "✅ 部署完成！"
echo "🌐 访问地址: http://节点IP:30999"
EOF

# 设置脚本执行权限
chmod +x scripts/*.sh

echo "✅ K8s部署支持添加完成！"
echo ""
echo "📋 使用方法："
echo "1. 本地测试: docker-compose up"
echo "2. K8s部署: ./scripts/build-images.sh && ./scripts/deploy-k8s.sh"
echo ""
echo "📁 项目结构："
echo "├── docker-compose.yml    # 本地快速测试"
echo "├── k8s/                  # K8s部署文件"
echo "├── scripts/              # 构建和部署脚本"
echo "└── 各个微服务目录"
