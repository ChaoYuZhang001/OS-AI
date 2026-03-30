#!/bin/bash
# GitHub推送脚本
# 使用Personal Access Token推送代码

# 请将YOUR_TOKEN替换为你的GitHub Personal Access Token
# 获取方式：GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
TOKEN="YOUR_TOKEN"

cd /tmp/OS-AI

# 更新remote URL，添加token
git remote set-url origin https://${TOKEN}@github.com/ChaoYuZhang001/OS-AI.git

# 推送代码
git push -u origin main

echo "✅ 推送完成！"

# 恢复原始URL（可选，为了安全）
# git remote set-url origin https://github.com/ChaoYuZhang001/OS-AI.git
