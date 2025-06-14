#!/bin/bash

# E-Commerce微服务Kubernetes部署脚本
# 作者: AI Assistant
# 用途: 一键部署所有微服务到Kubernetes集群

set -e

echo "🚀 开始部署E-Commerce微服务到Kubernetes..."

# 检查kubectl是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl未安装或不在PATH中"
    echo "请先安装kubectl或启用Docker Desktop的Kubernetes功能"
    exit 1
fi

# 检查集群连接
echo "🔍 检查Kubernetes集群连接..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 无法连接到Kubernetes集群"
    echo "请确保:"
    echo "  1. Docker Desktop已启动"
    echo "  2. Kubernetes功能已启用"
    echo "  3. 或者minikube已启动"
    exit 1
fi

echo "✅ Kubernetes集群连接正常"

# 创建命名空间
echo "📦 创建命名空间..."
kubectl apply -f namespace.yaml

# 等待命名空间创建完成
sleep 2

# 部署基础设施服务（按依赖顺序）
echo "🏗️  部署基础设施服务..."

echo "  - 部署服务发现(Eureka)..."
kubectl apply -f service-discovery.yaml

echo "  - 等待服务发现启动..."
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce-microservices --timeout=300s

echo "  - 部署配置中心..."
kubectl apply -f cloud-config.yaml

echo "  - 等待配置中心启动..."
kubectl wait --for=condition=ready pod -l app=cloud-config -n ecommerce-microservices --timeout=300s

echo "  - 部署API网关..."
kubectl apply -f api-gateway.yaml

# 部署业务服务
echo "🛍️  部署业务微服务..."

echo "  - 部署用户服务..."
kubectl apply -f user-service.yaml

echo "  - 部署业务服务(商品、订单、支付、物流)..."
kubectl apply -f business-services.yaml

# 部署监控服务
echo "📊 部署监控服务..."
kubectl apply -f monitoring.yaml

echo "⏳ 等待所有服务启动..."
sleep 30

# 检查部署状态
echo "🔍 检查部署状态..."
kubectl get pods -n ecommerce-microservices
kubectl get services -n ecommerce-microservices

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 服务访问信息："
echo "  - Eureka服务发现: http://localhost:8761 (需要端口转发)"
echo "  - API网关: http://localhost:8080 (需要端口转发)"
echo "  - Zipkin追踪: http://localhost:9411 (需要端口转发)"
echo ""
echo "🔧 端口转发命令："
echo "  kubectl port-forward -n ecommerce-microservices svc/service-discovery-service 8761:8761"
echo "  kubectl port-forward -n ecommerce-microservices svc/api-gateway-service 8080:8080"
echo "  kubectl port-forward -n ecommerce-microservices svc/zipkin-service 9411:9411"
echo ""
echo "📝 查看日志："
echo "  kubectl logs -f deployment/api-gateway -n ecommerce-microservices"
echo ""
echo "🗑️  删除部署："
echo "  kubectl delete namespace ecommerce-microservices"
