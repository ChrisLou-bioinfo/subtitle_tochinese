#!/bin/bash

# GitHub仓库初始化脚本

echo "🚀 YouTube双语字幕工具 - GitHub仓库初始化"
echo "=========================================="

# 检查是否在Git仓库中
if [ ! -d ".git" ]; then
    echo "❌ 当前目录不是Git仓库"
    echo "请先运行: git init"
    exit 1
fi

# 添加所有文件
echo "📦 添加文件到Git仓库..."
git add .

# 提交初始版本
echo "💾 提交初始版本..."
git commit -m "feat: 初始提交 - YouTube双语字幕生成工具"

echo ""
echo "✅ 初始化完成！"
echo ""
echo "📝 下一步操作:"
echo "1. 在GitHub上创建新的仓库"
echo "2. 添加远程仓库: git remote add origin https://github.com/yourusername/youtube-bilingual-subtitles.git"
echo "3. 推送代码: git push -u origin main"
echo ""
echo "🔑 重要提醒:"
echo "- 更新 README.md 中的仓库URL"
echo "- 确保 .env.example 文件包含正确的配置示例"
echo "- 测试工具功能是否正常"