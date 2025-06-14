#!/bin/bash

echo "🚀 在Play with Kubernetes上部署图书管理系统"

# 1. 创建命名空间
echo "📁 创建命名空间..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: library-system
EOF

# 2. 部署Eureka注册中心（使用现成的镜像）
echo "🔍 部署Eureka注册中心..."
cat <<EOF | kubectl apply -f -
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
        image: steeltoeoss/eureka-server:latest
        ports:
        - containerPort: 8761
        env:
        - name: EUREKA_CLIENT_REGISTER_WITH_EUREKA
          value: "false"
        - name: EUREKA_CLIENT_FETCH_REGISTRY
          value: "false"
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
  - port: 8761
    targetPort: 8761
    nodePort: 30761
  type: NodePort
EOF

# 3. 部署用户服务（模拟）
echo "👤 部署用户服务..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: library-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: user-config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: user-config
        configMap:
          name: user-service-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-service-config
  namespace: library-system
data:
  index.html: |
    <html>
    <head><title>用户服务</title></head>
    <body>
      <h1>图书管理系统 - 用户服务</h1>
      <p>服务状态: 运行中</p>
      <p>功能: 用户登录、注册、权限管理</p>
      <p>端口: 8001</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: library-system
spec:
  selector:
    app: user-service
  ports:
  - port: 8001
    targetPort: 80
    nodePort: 30001
  type: NodePort
EOF

# 4. 部署图书服务
echo "📚 部署图书服务..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: book-service
  namespace: library-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: book-service
  template:
    metadata:
      labels:
        app: book-service
    spec:
      containers:
      - name: book-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: book-config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: book-config
        configMap:
          name: book-service-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: book-service-config
  namespace: library-system
data:
  index.html: |
    <html>
    <head><title>图书服务</title></head>
    <body>
      <h1>图书管理系统 - 图书服务</h1>
      <p>服务状态: 运行中</p>
      <p>功能: 图书增删改查、库存管理</p>
      <p>端口: 8002</p>
      <ul>
        <li>Java编程思想 - 可借阅</li>
        <li>Spring实战 - 可借阅</li>
        <li>微服务架构设计 - 已借出</li>
      </ul>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: book-service
  namespace: library-system
spec:
  selector:
    app: book-service
  ports:
  - port: 8002
    targetPort: 80
    nodePort: 30002
  type: NodePort
EOF

# 5. 部署借阅服务
echo "📖 部署借阅服务..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: borrow-service
  namespace: library-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: borrow-service
  template:
    metadata:
      labels:
        app: borrow-service
    spec:
      containers:
      - name: borrow-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: borrow-config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: borrow-config
        configMap:
          name: borrow-service-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: borrow-service-config
  namespace: library-system
data:
  index.html: |
    <html>
    <head><title>借阅服务</title></head>
    <body>
      <h1>图书管理系统 - 借阅服务</h1>
      <p>服务状态: 运行中</p>
      <p>功能: 图书借阅、归还、续借</p>
      <p>端口: 8003</p>
      <h3>当前借阅记录:</h3>
      <ul>
        <li>用户001 - 《微服务架构设计》- 2024-06-10借出</li>
        <li>用户002 - 《云原生应用架构》- 2024-06-12借出</li>
      </ul>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: borrow-service
  namespace: library-system
spec:
  selector:
    app: borrow-service
  ports:
  - port: 8003
    targetPort: 80
    nodePort: 30003
  type: NodePort
EOF

# 6. 等待所有服务启动
echo "⏳ 等待服务启动..."
kubectl wait --for=condition=ready pod -l app=eureka-service -n library-system --timeout=300s
kubectl wait --for=condition=ready pod -l app=user-service -n library-system --timeout=300s
kubectl wait --for=condition=ready pod -l app=book-service -n library-system --timeout=300s
kubectl wait --for=condition=ready pod -l app=borrow-service -n library-system --timeout=300s

# 7. 显示部署结果
echo "✅ 部署完成！"
echo ""
echo "📊 服务状态:"
kubectl get pods -n library-system
echo ""
echo "🌐 访问地址:"
echo "- Eureka注册中心: http://节点IP:30761"
echo "- 用户服务: http://节点IP:30001"  
echo "- 图书服务: http://节点IP:30002"
echo "- 借阅服务: http://节点IP:30003"
echo ""
echo "💡 获取节点IP: kubectl get nodes -o wide"
