#!/bin/bash

# E-Commerce微服务Kubernetes清理脚本
# 作者: AI Assistant
# 用途: 清理所有部署的微服务

set -e

echo "🗑️  开始清理E-Commerce微服务部署..."

# 检查kubectl是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl未安装或不在PATH中"
    exit 1
fi

# 检查命名空间是否存在
if kubectl get namespace ecommerce-microservices &> /dev/null; then
    echo "📦 删除命名空间和所有资源..."
    kubectl delete namespace ecommerce-microservices
    
    echo "⏳ 等待资源清理完成..."
    while kubectl get namespace ecommerce-microservices &> /dev/null; do
        echo "  等待命名空间删除..."
        sleep 5
    done
    
    echo "✅ 清理完成！"
else
    echo "ℹ️  命名空间 ecommerce-microservices 不存在，无需清理"
fi

echo "🎉 所有资源已清理完毕！"
