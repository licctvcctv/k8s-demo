#!/bin/bash

# 简化版K8s部署脚本
echo "🚀 开始简化部署..."

# 检查kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl未找到"
    exit 1
fi

# 部署
echo "📦 部署基础服务..."
kubectl apply -f simple-deploy.yaml

echo "⏳ 等待Pod启动..."
sleep 30

echo "🔍 检查状态..."
kubectl get pods -n ecommerce-microservices
kubectl get services -n ecommerce-microservices

echo "✅ 部署完成！"
echo ""
echo "🌐 访问服务："
echo "  kubectl port-forward -n ecommerce-microservices svc/service-discovery-service 8761:8761"
echo "  kubectl port-forward -n ecommerce-microservices svc/api-gateway-service 8080:8080"
