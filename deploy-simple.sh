#!/bin/bash

echo "🚀 一键部署图书管理微服务系统"
echo "================================"

# 创建命名空间
kubectl create namespace library-system

# 一键部署所有服务
cat <<EOF | kubectl apply -f -
# 用户服务
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: library-system
spec:
  replicas: 1
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
        command: ["/bin/sh"]
        args: ["-c", "echo '<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>用户管理服务</title><style>body{font-family:Arial;margin:40px;background:#f0f8ff}.container{max-width:800px;margin:0 auto;background:white;padding:30px;border-radius:10px}h1{color:#2c3e50;text-align:center}table{width:100%;border-collapse:collapse;margin:20px 0}th,td{border:1px solid #ddd;padding:12px;text-align:left}th{background:#3498db;color:white}</style></head><body><div class=\"container\"><h1>👤 用户管理服务</h1><p><strong>状态:</strong> 运行中</p><p><strong>端口:</strong> 8080</p><h3>🔐 功能模块</h3><ul><li>用户认证</li><li>用户注册</li><li>权限管理</li><li>JWT令牌</li></ul><h3>👥 测试用户</h3><table><tr><th>用户名</th><th>密码</th><th>角色</th></tr><tr><td>admin</td><td>123456</td><td>管理员</td></tr><tr><td>user1</td><td>123456</td><td>普通用户</td></tr><tr><td>user2</td><td>123456</td><td>普通用户</td></tr></table></div></body></html>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
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
  - port: 80
    targetPort: 80
  type: ClusterIP
---
# 图书服务
apiVersion: apps/v1
kind: Deployment
metadata:
  name: book-service
  namespace: library-system
spec:
  replicas: 1
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
        command: ["/bin/sh"]
        args: ["-c", "echo '<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>图书管理服务</title><style>body{font-family:Arial;margin:40px;background:#f0fff0}.container{max-width:800px;margin:0 auto;background:white;padding:30px;border-radius:10px}h1{color:#27ae60;text-align:center}table{width:100%;border-collapse:collapse;margin:20px 0}th,td{border:1px solid #ddd;padding:12px;text-align:left}th{background:#27ae60;color:white}</style></head><body><div class=\"container\"><h1>📚 图书管理服务</h1><p><strong>状态:</strong> 运行中</p><p><strong>端口:</strong> 8081</p><h3>📖 功能模块</h3><ul><li>图书信息管理</li><li>库存管理</li><li>图书搜索</li><li>分类管理</li></ul><h3>📊 图书库存</h3><table><tr><th>书名</th><th>作者</th><th>总数</th><th>可借</th></tr><tr><td>Java编程思想</td><td>Bruce Eckel</td><td>15</td><td>12</td></tr><tr><td>Spring实战</td><td>Craig Walls</td><td>20</td><td>16</td></tr><tr><td>微服务架构设计</td><td>Sam Newman</td><td>12</td><td>8</td></tr><tr><td>Kubernetes权威指南</td><td>龚正</td><td>10</td><td>7</td></tr></table></div></body></html>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
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
  - port: 80
    targetPort: 80
  type: ClusterIP
---
# 借阅服务
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
        command: ["/bin/sh"]
        args: ["-c", "echo '<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>借阅管理服务</title><style>body{font-family:Arial;margin:40px;background:#fff8dc}.container{max-width:800px;margin:0 auto;background:white;padding:30px;border-radius:10px}h1{color:#e67e22;text-align:center}table{width:100%;border-collapse:collapse;margin:20px 0}th,td{border:1px solid #ddd;padding:12px;text-align:left}th{background:#e67e22;color:white}</style></head><body><div class=\"container\"><h1>📖 借阅管理服务</h1><p><strong>状态:</strong> 运行中</p><p><strong>端口:</strong> 8082</p><h3>📋 功能模块</h3><ul><li>图书借阅</li><li>图书归还</li><li>续借管理</li><li>逾期提醒</li></ul><h3>📈 借阅记录</h3><table><tr><th>用户</th><th>图书</th><th>借阅日期</th><th>状态</th></tr><tr><td>user1</td><td>微服务架构设计</td><td>2024-06-10</td><td>借阅中</td></tr><tr><td>user2</td><td>Spring实战</td><td>2024-06-12</td><td>借阅中</td></tr><tr><td>admin</td><td>Java编程思想</td><td>2024-06-08</td><td>已归还</td></tr></table></div></body></html>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
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
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "⏳ 等待服务启动..."
sleep 20

echo "🔍 检查部署状态..."
kubectl get pods -n library-system
kubectl get services -n library-system

echo "🚀 启动端口转发..."
kubectl port-forward -n library-system service/user-service 8080:80 --address=0.0.0.0 &
kubectl port-forward -n library-system service/book-service 8081:80 --address=0.0.0.0 &
kubectl port-forward -n library-system service/borrow-service 8082:80 --address=0.0.0.0 &

sleep 3

echo ""
echo "🎉 部署完成！"
echo "================================"
echo ""
echo "🌐 在Killercoda Traffic Port Accessor中输入："
echo "8080 - 用户服务"
echo "8081 - 图书服务"  
echo "8082 - 借阅服务"
echo ""
echo "🧪 测试命令："
echo "curl http://localhost:8080"
echo ""
echo "🧹 清理命令："
echo "kubectl delete namespace library-system"
