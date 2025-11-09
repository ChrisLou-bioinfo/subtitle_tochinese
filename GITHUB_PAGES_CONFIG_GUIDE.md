# GitHub Pages 详细配置指南

## 当前状态
❌ GitHub Pages 尚未启用

## 手动配置步骤

### 步骤1：访问GitHub仓库设置
1. 打开浏览器，访问：https://github.com/ChrisLou-bioinfo/subtitle_tochinese
2. 点击右上角的 "Settings" 选项卡

### 步骤2：配置GitHub Pages
1. 在左侧菜单中找到 "Pages"
2. 在 "Build and deployment" 部分，选择 "Source"
3. 选择 "GitHub Actions" 作为源
4. 点击 "Save" 保存设置

### 步骤3：等待首次部署
1. GitHub Actions会自动触发部署工作流
2. 查看部署状态：
   - 点击仓库顶部的 "Actions" 选项卡
   - 查看 "Deploy to GitHub Pages" 工作流
   - 等待部署完成（约2-5分钟）

### 步骤4：验证部署
部署完成后，可以通过以下URL访问：
- https://chrislou-bioinfo.github.io/subtitle_tochinese/
- https://chrislou-bioinfo.github.io/subtitle_tochinese/support.html
- https://chrislou-bioinfo.github.io/subtitle_tochinese/privacy.html

## 替代方案：使用docs文件夹

如果GitHub Actions部署有问题，可以改用docs文件夹方式：

### 步骤1：更改GitHub Pages源
1. 在 "Settings" → "Pages"
2. 选择 "Source" → "Deploy from a branch"
3. 选择分支："main"
4. 选择文件夹："/docs"
5. 点击 "Save"

### 步骤2：重新组织文件结构
如果使用docs文件夹方式，需要：
1. 确保所有HTML文件都在docs文件夹内
2. 删除.github/workflows/deploy.yml文件
3. 提交更改

## 故障排除

### 页面显示404错误
- 确认GitHub Pages已启用
- 检查URL是否正确
- 等待部署完成

### GitHub Actions部署失败
- 检查.github/workflows/deploy.yml语法
- 查看Actions日志中的错误信息
- 确保docs文件夹存在且包含HTML文件

### 自定义域名配置（可选）
如果需要使用自定义域名：
1. 在仓库根目录创建CNAME文件
2. 文件中写入您的域名
3. 在域名DNS中添加CNAME记录指向GitHub Pages

## App Store 网址设置

配置完成后，在App Store Connect中设置：

### 技术支持网址
```
https://chrislou-bioinfo.github.io/subtitle_tochinese/support.html
```

### 隐私政策网址
```
https://chrislou-bioinfo.github.io/subtitle_tochinese/privacy.html
```

## 验证页面内容

部署成功后，检查以下页面是否正常显示：

1. **首页**：应显示应用介绍和功能特点
2. **技术支持**：应显示FAQ和使用教程
3. **隐私政策**：应显示隐私保护说明

## 联系方式

如有配置问题，请联系：chrislou.bioinfo@gmail.com