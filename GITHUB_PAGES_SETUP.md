# GitHub Pages 部署指南

## 部署状态
✅ 代码已推送到GitHub仓库：https://github.com/ChrisLou-bioinfo/subtitle_tochinese

## GitHub Pages 设置步骤

### 1. 启用GitHub Pages
1. 访问GitHub仓库：https://github.com/ChrisLou-bioinfo/subtitle_tochinese
2. 点击 "Settings" 选项卡
3. 在左侧菜单中找到 "Pages"
4. 在 "Source" 部分选择 "GitHub Actions"
5. 保存设置

### 2. 等待自动部署
- GitHub Actions会自动构建和部署页面
- 部署完成后，页面将可通过以下URL访问：
  - **主页面**：https://chrislou-bioinfo.github.io/subtitle_tochinese/
  - **技术支持**：https://chrislou-bioinfo.github.io/subtitle_tochinese/support.html
  - **隐私政策**：https://chrislou-bioinfo.github.io/subtitle_tochinese/privacy.html

### 3. 检查部署状态
1. 在GitHub仓库中点击 "Actions" 选项卡
2. 查看 "Deploy to GitHub Pages" 工作流的状态
3. 如果部署成功，会显示绿色的勾号

## App Store 技术支持网址

在App Store Connect中设置技术支持网址：
```
https://chrislou-bioinfo.github.io/subtitle_tochinese/support.html
```

## 隐私政策网址

在App Store Connect中设置隐私政策网址：
```
https://chrislou-bioinfo.github.io/subtitle_tochinese/privacy.html
```

## 页面内容说明

### 📱 首页 (index.html)
- 应用功能介绍
- 使用场景说明
- 快速开始指南
- 联系方式

### ❓ 技术支持 (support.html)
- 常见问题解答
- 使用教程
- 故障排除指南
- 联系方式

### 🔒 隐私政策 (privacy.html)
- 数据处理方式说明
- 隐私保护承诺
- 联系方式

## 自定义域名（可选）

如果需要使用自定义域名：
1. 在仓库根目录创建 `CNAME` 文件
2. 文件中写入您的域名，例如：`srt-translator.com`
3. 在域名DNS设置中添加CNAME记录指向GitHub Pages

## 故障排除

### 页面无法访问
- 检查GitHub Actions部署状态
- 确认GitHub Pages已启用
- 检查URL是否正确

### 内容显示异常
- 检查HTML文件语法
- 确认CSS样式正确加载
- 查看浏览器控制台错误信息

## 更新内容

要更新页面内容：
1. 修改 `docs/` 目录下的HTML文件
2. 提交更改到GitHub
3. GitHub Actions会自动重新部署

## 技术支持

如有问题请联系：chrislou.bioinfo@gmail.com