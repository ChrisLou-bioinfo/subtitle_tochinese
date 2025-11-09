# GitHub仓库设置指南

## 1. 创建GitHub仓库

### 方法一：通过GitHub网站创建
1. 访问 https://github.com/new
2. 填写仓库信息：
   - Repository name: `subtitle_tochinese`
   - Description: `双语字幕翻译工具 - iOS应用`
   - Public/Private: 选择Public（公开）
   - 勾选"Add a README file"
   - 点击"Create repository"

### 方法二：通过GitHub CLI创建
```bash
gh repo create subtitle_tochinese --public --description="双语字幕翻译工具 - iOS应用"
```

## 2. 连接本地仓库到GitHub

### 设置远程仓库
```bash
cd /Users/chris/VScode/subtitle_tochinese
git remote add origin https://github.com/ChrisLou-bioinfo/subtitle_tochinese.git
```

### 首次推送代码
```bash
git add .
git commit -m "Initial commit: 双语字幕翻译iOS应用"
git branch -M main
git push -u origin main
```

## 3. 设置GitHub Pages

### 启用GitHub Pages
1. 在GitHub仓库页面，点击"Settings"
2. 左侧菜单选择"Pages"
3. Source选择"GitHub Actions"
4. 保存设置

### 创建GitHub Actions工作流
在项目根目录创建 `.github/workflows/deploy.yml`：

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Pages
      uses: actions/configure-pages@v3
    - name: Upload artifact
      uses: actions/upload-pages-artifact@v2
      with:
        path: './docs'
    - name: Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v2
```

## 4. 更新iOS应用中的链接

### 修改ContentView_v2.swift中的链接
将以下链接更新为您的GitHub仓库地址：

```swift
Link("隐私政策", destination: URL(string: "https://chrislou-bioinfo.github.io/subtitle_tochinese/privacy.html")!)
Link("技术支持", destination: URL(string: "https://github.com/ChrisLou-bioinfo/subtitle_tochinese")!)
```

## 5. Info.plist文件处理

### Xcode中创建Info.plist
1. 在Xcode项目中，右键点击项目文件夹
2. 选择"New File"
3. 选择"Property List"
4. 命名为"Info.plist"
5. 添加以下键值对：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>双语字幕翻译</string>
    <key>CFBundleName</key>
    <string>双语字幕翻译</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.5</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
</dict>
</plist>
```

### 或者使用现有的Info.plist文件
如果您已经在iOS_App_Code文件夹中创建了Info.plist，可以将其复制到Xcode项目中。

## 6. 技术支持页面

### 创建GitHub Issues模板
在项目根目录创建 `.github/ISSUE_TEMPLATE/bug_report.md`：

```markdown
---
name: Bug报告
about: 报告应用中的问题
labels: bug

---

## 问题描述

## 重现步骤

## 期望行为

## 截图（如有）

## 环境信息
- 设备型号：
- iOS版本：
- 应用版本：
```

## 7. 最终验证

### 验证GitHub Pages
访问：https://chrislou-bioinfo.github.io/subtitle_tochinese/privacy.html

### 验证GitHub仓库
访问：https://github.com/ChrisLou-bioinfo/subtitle_tochinese

### 验证App Store Connect设置
在App Store Connect中更新：
- 技术支持网址：https://github.com/ChrisLou-bioinfo/subtitle_tochinese
- 营销网址：https://chrislou-bioinfo.github.io/subtitle_tochinese/

## 常见问题

### Q: GitHub仓库无法访问
A: 检查仓库是否为公开状态，确保URL正确

### Q: GitHub Pages无法显示
A: 检查GitHub Actions是否成功运行，查看部署日志

### Q: Info.plist在Xcode中不显示
A: 确保文件已添加到项目中，检查文件路径

完成以上步骤后，您的应用将完全符合Apple App Store的审核要求。