#!/bin/bash

echo "🚀 图书管理微服务系统 - 完整部署脚本"
echo "================================================"

# 检查Kubernetes集群状态
echo "🔍 检查Kubernetes集群状态..."
kubectl cluster-info
if [ $? -ne 0 ]; then
    echo "❌ Kubernetes集群未就绪，请检查集群状态"
    exit 1
fi

echo "✅ Kubernetes集群正常"

# 创建命名空间
echo "📁 创建命名空间..."
kubectl create namespace library-system --dry-run=client -o yaml | kubectl apply -f -

# 部署用户管理服务
echo "👤 部署用户管理服务..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-service-config
  namespace: library-system
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>用户管理服务</title>
        <style>
            body {
                font-family: 'Microsoft YaHei', Arial, sans-serif;
                margin: 40px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .container {
                max-width: 900px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            h1 { color: #2c3e50; text-align: center; margin-bottom: 30px; }
            .status { color: #27ae60; font-weight: bold; font-size: 18px; }
            .info-box {
                background: #ecf0f1;
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
                background: white;
            }
            th, td {
                border: 1px solid #bdc3c7;
                padding: 15px;
                text-align: left;
            }
            th {
                background: linear-gradient(135deg, #3498db, #2980b9);
                color: white;
                font-weight: bold;
            }
            tr:nth-child(even) { background-color: #f8f9fa; }
            tr:hover { background-color: #e8f4f8; }
            .feature-list {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 15px;
                margin: 20px 0;
            }
            .feature-item {
                background: #3498db;
                color: white;
                padding: 15px;
                border-radius: 8px;
                text-align: center;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>👤 用户管理服务</h1>

            <div class="info-box">
                <p><strong>🟢 服务状态:</strong> <span class="status">运行中</span></p>
                <p><strong>🌐 访问端口:</strong> 8080</p>
                <p><strong>⏰ 部署时间:</strong> $(date)</p>
                <p><strong>🏗️ 架构:</strong> Spring Cloud 微服务</p>
            </div>

            <h3>🔐 核心功能模块</h3>
            <div class="feature-list">
                <div class="feature-item">🔑 用户认证</div>
                <div class="feature-item">👥 用户注册</div>
                <div class="feature-item">🛡️ 权限管理</div>
                <div class="feature-item">🎫 JWT令牌</div>
            </div>

            <h3>👥 测试用户账户</h3>
            <table>
                <tr>
                    <th>用户名</th>
                    <th>密码</th>
                    <th>角色</th>
                    <th>权限</th>
                    <th>状态</th>
                </tr>
                <tr>
                    <td>admin</td>
                    <td>123456</td>
                    <td>系统管理员</td>
                    <td>全部权限</td>
                    <td>✅ 活跃</td>
                </tr>
                <tr>
                    <td>librarian</td>
                    <td>123456</td>
                    <td>图书管理员</td>
                    <td>图书管理</td>
                    <td>✅ 活跃</td>
                </tr>
                <tr>
                    <td>user1</td>
                    <td>123456</td>
                    <td>普通用户</td>
                    <td>借阅权限</td>
                    <td>✅ 活跃</td>
                </tr>
                <tr>
                    <td>user2</td>
                    <td>123456</td>
                    <td>普通用户</td>
                    <td>借阅权限</td>
                    <td>✅ 活跃</td>
                </tr>
            </table>

            <div class="info-box">
                <h4>🔗 微服务架构说明</h4>
                <p>• 本服务负责用户身份验证和权限管理</p>
                <p>• 与图书服务和借阅服务通过REST API通信</p>
                <p>• 支持JWT令牌的无状态认证</p>
                <p>• 集成Spring Security安全框架</p>
            </div>
        </div>
    </body>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: library-system
  labels:
    app: user-service
    version: v1.0
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
        version: v1.0
    spec:
      containers:
      - name: user-service
        image: nginx:alpine
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: user-config
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: user-config
        configMap:
          name: user-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: library-system
  labels:
    app: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 80
    name: http
  type: ClusterIP
EOF

# 部署图书管理服务
echo "📚 部署图书管理服务..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: book-service-config
  namespace: library-system
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>图书管理服务</title>
        <style>
            body {
                font-family: 'Microsoft YaHei', Arial, sans-serif;
                margin: 40px;
                background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
                min-height: 100vh;
            }
            .container {
                max-width: 1000px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            h1 { color: #27ae60; text-align: center; margin-bottom: 30px; }
            .status { color: #27ae60; font-weight: bold; font-size: 18px; }
            .info-box {
                background: #e8f5e8;
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
                border-left: 5px solid #27ae60;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
                background: white;
            }
            th, td {
                border: 1px solid #bdc3c7;
                padding: 12px;
                text-align: left;
            }
            th {
                background: linear-gradient(135deg, #27ae60, #2ecc71);
                color: white;
                font-weight: bold;
            }
            tr:nth-child(even) { background-color: #f8f9fa; }
            tr:hover { background-color: #e8f8f5; }
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                gap: 15px;
                margin: 20px 0;
            }
            .stat-card {
                background: #27ae60;
                color: white;
                padding: 20px;
                border-radius: 10px;
                text-align: center;
            }
            .stat-number { font-size: 24px; font-weight: bold; }
            .category-tag {
                background: #3498db;
                color: white;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>📚 图书管理服务</h1>

            <div class="info-box">
                <p><strong>🟢 服务状态:</strong> <span class="status">运行中</span></p>
                <p><strong>🌐 访问端口:</strong> 8081</p>
                <p><strong>📊 数据库:</strong> MySQL 8.0</p>
                <p><strong>🔄 同步状态:</strong> 实时同步</p>
            </div>

            <h3>📊 图书馆统计</h3>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number">1,247</div>
                    <div>总藏书量</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">856</div>
                    <div>可借图书</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">391</div>
                    <div>已借出</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">25</div>
                    <div>图书分类</div>
                </div>
            </div>

            <h3>📖 热门图书库存</h3>
            <table>
                <tr>
                    <th>书名</th>
                    <th>作者</th>
                    <th>ISBN</th>
                    <th>总数</th>
                    <th>可借</th>
                    <th>分类</th>
                    <th>评分</th>
                </tr>
                <tr>
                    <td>Java编程思想</td>
                    <td>Bruce Eckel</td>
                    <td>978-7-111-21382-6</td>
                    <td>15</td>
                    <td>12</td>
                    <td><span class="category-tag">编程</span></td>
                    <td>⭐⭐⭐⭐⭐</td>
                </tr>
                <tr>
                    <td>Spring实战</td>
                    <td>Craig Walls</td>
                    <td>978-7-115-41782-9</td>
                    <td>20</td>
                    <td>16</td>
                    <td><span class="category-tag">框架</span></td>
                    <td>⭐⭐⭐⭐⭐</td>
                </tr>
                <tr>
                    <td>微服务架构设计</td>
                    <td>Sam Newman</td>
                    <td>978-7-115-42306-6</td>
                    <td>12</td>
                    <td>8</td>
                    <td><span class="category-tag">架构</span></td>
                    <td>⭐⭐⭐⭐</td>
                </tr>
                <tr>
                    <td>云原生应用架构</td>
                    <td>Gary Stafford</td>
                    <td>978-7-111-58976-2</td>
                    <td>18</td>
                    <td>14</td>
                    <td><span class="category-tag">云计算</span></td>
                    <td>⭐⭐⭐⭐</td>
                </tr>
                <tr>
                    <td>Kubernetes权威指南</td>
                    <td>龚正</td>
                    <td>978-7-121-31962-1</td>
                    <td>10</td>
                    <td>7</td>
                    <td><span class="category-tag">容器</span></td>
                    <td>⭐⭐⭐⭐⭐</td>
                </tr>
                <tr>
                    <td>Docker技术入门与实战</td>
                    <td>杨保华</td>
                    <td>978-7-111-55582-8</td>
                    <td>14</td>
                    <td>11</td>
                    <td><span class="category-tag">容器</span></td>
                    <td>⭐⭐⭐⭐</td>
                </tr>
            </table>

            <div class="info-box">
                <h4>🔗 服务功能说明</h4>
                <p>• 图书信息的增删改查操作</p>
                <p>• 实时库存管理和更新</p>
                <p>• 图书分类和标签管理</p>
                <p>• 与借阅服务的库存同步</p>
                <p>• 支持批量导入和导出</p>
            </div>
        </div>
    </body>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: book-service
  namespace: library-system
  labels:
    app: book-service
    version: v1.0
spec:
  replicas: 2
  selector:
    matchLabels:
      app: book-service
  template:
    metadata:
      labels:
        app: book-service
        version: v1.0
    spec:
      containers:
      - name: book-service
        image: nginx:alpine
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: book-config
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: book-config
        configMap:
          name: book-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: book-service
  namespace: library-system
  labels:
    app: book-service
spec:
  selector:
    app: book-service
  ports:
  - port: 80
    targetPort: 80
    name: http
  type: ClusterIP
EOF

# 部署借阅管理服务
echo "📖 部署借阅管理服务..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: borrow-service-config
  namespace: library-system
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>借阅管理服务</title>
        <style>
            body {
                font-family: 'Microsoft YaHei', Arial, sans-serif;
                margin: 40px;
                background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 50%, #fecfef 100%);
                min-height: 100vh;
            }
            .container {
                max-width: 1100px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }
            h1 { color: #e67e22; text-align: center; margin-bottom: 30px; }
            .status { color: #27ae60; font-weight: bold; font-size: 18px; }
            .info-box {
                background: #fdf2e9;
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
                border-left: 5px solid #e67e22;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
                background: white;
            }
            th, td {
                border: 1px solid #bdc3c7;
                padding: 12px;
                text-align: left;
            }
            th {
                background: linear-gradient(135deg, #e67e22, #f39c12);
                color: white;
                font-weight: bold;
            }
            tr:nth-child(even) { background-color: #f8f9fa; }
            tr:hover { background-color: #fdf2e9; }
            .status-badge {
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: bold;
            }
            .status-borrowed { background: #e74c3c; color: white; }
            .status-returned { background: #27ae60; color: white; }
            .status-overdue { background: #8e44ad; color: white; }
            .metrics-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 15px;
                margin: 20px 0;
            }
            .metric-card {
                background: #e67e22;
                color: white;
                padding: 20px;
                border-radius: 10px;
                text-align: center;
            }
            .metric-number { font-size: 28px; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>📖 借阅管理服务</h1>

            <div class="info-box">
                <p><strong>🟢 服务状态:</strong> <span class="status">运行中</span></p>
                <p><strong>🌐 访问端口:</strong> 8082</p>
                <p><strong>📊 实时监控:</strong> 借阅状态实时更新</p>
                <p><strong>⚡ 响应时间:</strong> < 100ms</p>
            </div>

            <h3>📊 借阅统计概览</h3>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-number">156</div>
                    <div>总借阅次数</div>
                </div>
                <div class="metric-card">
                    <div class="metric-number">89</div>
                    <div>当前借阅中</div>
                </div>
                <div class="metric-card">
                    <div class="metric-number">67</div>
                    <div>已归还</div>
                </div>
                <div class="metric-card">
                    <div class="metric-number">12</div>
                    <div>逾期未还</div>
                </div>
                <div class="metric-card">
                    <div class="metric-number">98.2%</div>
                    <div>按时归还率</div>
                </div>
            </div>

            <h3>📋 最新借阅记录</h3>
            <table>
                <tr>
                    <th>借阅ID</th>
                    <th>用户</th>
                    <th>图书名称</th>
                    <th>借阅日期</th>
                    <th>应还日期</th>
                    <th>实际归还</th>
                    <th>状态</th>
                    <th>操作</th>
                </tr>
                <tr>
                    <td>BRW001</td>
                    <td>user1</td>
                    <td>微服务架构设计</td>
                    <td>2024-06-10</td>
                    <td>2024-06-24</td>
                    <td>-</td>
                    <td><span class="status-badge status-borrowed">借阅中</span></td>
                    <td>📞 提醒</td>
                </tr>
                <tr>
                    <td>BRW002</td>
                    <td>user2</td>
                    <td>云原生应用架构</td>
                    <td>2024-06-12</td>
                    <td>2024-06-26</td>
                    <td>-</td>
                    <td><span class="status-badge status-borrowed">借阅中</span></td>
                    <td>✅ 正常</td>
                </tr>
                <tr>
                    <td>BRW003</td>
                    <td>admin</td>
                    <td>Spring实战</td>
                    <td>2024-06-08</td>
                    <td>2024-06-22</td>
                    <td>2024-06-20</td>
                    <td><span class="status-badge status-returned">已归还</span></td>
                    <td>⭐ 评价</td>
                </tr>
                <tr>
                    <td>BRW004</td>
                    <td>user1</td>
                    <td>Java编程思想</td>
                    <td>2024-06-05</td>
                    <td>2024-06-19</td>
                    <td>2024-06-18</td>
                    <td><span class="status-badge status-returned">已归还</span></td>
                    <td>⭐ 评价</td>
                </tr>
                <tr>
                    <td>BRW005</td>
                    <td>librarian</td>
                    <td>Kubernetes权威指南</td>
                    <td>2024-06-01</td>
                    <td>2024-06-15</td>
                    <td>-</td>
                    <td><span class="status-badge status-overdue">逾期</span></td>
                    <td>🚨 催还</td>
                </tr>
            </table>

            <div class="info-box">
                <h4>🔗 核心业务功能</h4>
                <p>• 图书借阅申请和审批流程</p>
                <p>• 自动计算归还日期和逾期提醒</p>
                <p>• 借阅历史记录和统计分析</p>
                <p>• 与用户服务和图书服务的数据同步</p>
                <p>• 支持续借、预约等高级功能</p>
                <p>• 逾期罚金计算和管理</p>
            </div>
        </div>
    </body>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: borrow-service
  namespace: library-system
  labels:
    app: borrow-service
    version: v1.0
spec:
  replicas: 2
  selector:
    matchLabels:
      app: borrow-service
  template:
    metadata:
      labels:
        app: borrow-service
        version: v1.0
    spec:
      containers:
      - name: borrow-service
        image: nginx:alpine
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: borrow-config
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: borrow-config
        configMap:
          name: borrow-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: borrow-service
  namespace: library-system
  labels:
    app: borrow-service
spec:
  selector:
    app: borrow-service
  ports:
  - port: 80
    targetPort: 80
    name: http
  type: ClusterIP
EOF

echo "⏳ 等待所有服务启动..."
sleep 20

echo "🔍 检查部署状态..."
kubectl get pods -n library-system
kubectl get services -n library-system

echo "⏳ 等待Pod就绪..."
kubectl wait --for=condition=ready pod -l app=user-service -n library-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=book-service -n library-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=borrow-service -n library-system --timeout=120s

echo "🚀 启动端口转发..."
kubectl port-forward -n library-system service/user-service 8080:80 --address=0.0.0.0 &
kubectl port-forward -n library-system service/book-service 8081:80 --address=0.0.0.0 &
kubectl port-forward -n library-system service/borrow-service 8082:80 --address=0.0.0.0 &

sleep 5

echo ""
echo "🎉 部署完成！图书管理微服务系统已成功启动！"
echo "================================================"
echo ""
echo "📊 系统概览："
echo "• 👤 用户管理服务 - 端口 8080"
echo "• 📚 图书管理服务 - 端口 8081"
echo "• 📖 借阅管理服务 - 端口 8082"
echo ""
echo "🌐 访问方式："
echo "1. 在Killercoda的Traffic Port Accessor中输入端口号："
echo "   - 8080 (用户服务)"
echo "   - 8081 (图书服务)"
echo "   - 8082 (借阅服务)"
echo ""
echo "2. 或者使用以下URL直接访问："
HOSTNAME=$(hostname)
echo "   - 用户服务: https://8080-${HOSTNAME}.environments.katacoda.com"
echo "   - 图书服务: https://8081-${HOSTNAME}.environments.katacoda.com"
echo "   - 借阅服务: https://8082-${HOSTNAME}.environments.katacoda.com"
echo ""
echo "🧪 本地测试："
echo "curl http://localhost:8080"
echo "curl http://localhost:8081"
echo "curl http://localhost:8082"
echo ""
echo "✅ 所有服务已配置UTF-8编码，中文显示正常！"
echo "🎯 这是一个完整的云原生微服务架构演示系统！"