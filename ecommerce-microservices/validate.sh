#!/bin/bash

# K8s配置文件验证脚本
echo "🔍 验证Kubernetes配置文件..."

# 验证YAML语法
echo "📋 检查YAML语法..."

files=(
    "namespace.yaml"
    "service-discovery.yaml" 
    "cloud-config.yaml"
    "api-gateway.yaml"
    "user-service.yaml"
    "business-services.yaml"
    "monitoring.yaml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  检查 $file..."
        if kubectl apply --dry-run=client -f "$file" > /dev/null 2>&1; then
            echo "  ✅ $file 语法正确"
        else
            echo "  ❌ $file 语法错误"
            kubectl apply --dry-run=client -f "$file"
        fi
    else
        echo "  ⚠️  $file 不存在"
    fi
done

echo ""
echo "🎉 验证完成！"
