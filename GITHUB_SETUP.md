# GitHub仓库设置指南

## 🚀 将项目发布到GitHub

### 步骤1: 准备项目

确保所有文件都已准备就绪：

```bash
# 检查项目结构
ls -la
```

应该包含以下关键文件：
- `README.md` - 项目说明文档
- `youtube_downloader.py` - 主程序
- `requirements.txt` - 依赖列表
- `.gitignore` - Git忽略文件
- `.env.example` - 配置文件示例
- `LICENSE` - MIT许可证
- `setup.py` - 安装脚本
- `init_repo.sh` - 仓库初始化脚本

### 步骤2: 初始化Git仓库

```bash
# 如果还没有初始化Git
git init

# 运行初始化脚本
./init_repo.sh
```

### 步骤3: 创建GitHub仓库

1. 登录GitHub
2. 点击右上角 "+" → "New repository"
3. 填写仓库信息：
   - **Repository name**: `youtube-bilingual-subtitles`
   - **Description**: `YouTube视频下载与双语字幕生成工具`
   - **Public/Private**: 选择公开或私有
   - **Initialize with README**: 取消勾选（我们已经有README.md）
4. 点击 "Create repository"

### 步骤4: 连接本地仓库

```bash
# 添加远程仓库（替换yourusername为你的GitHub用户名）
git remote add origin https://github.com/yourusername/youtube-bilingual-subtitles.git

# 推送代码
git push -u origin main
```

### 步骤5: 更新README.md

编辑 `README.md`，更新仓库URL：

```markdown
# YouTube双语字幕生成工具

[![GitHub stars](https://img.shields.io/github/stars/yourusername/youtube-bilingual-subtitles?style=social)](https://github.com/yourusername/youtube-bilingual-subtitles)

这是一个完整的YouTube视频下载、字幕翻译和视频合并工具...

## 快速开始

### 1. 克隆仓库
```bash
git clone https://github.com/yourusername/youtube-bilingual-subtitles.git
cd youtube-bilingual-subtitles
```
```

### 步骤6: 添加GitHub标签和主题

在GitHub仓库页面添加相关标签：
- `python`
- `youtube`
- `subtitles`
- `translation`
- `ffmpeg`

### 步骤7: 创建发布版本

当项目稳定后，可以创建GitHub Release：

```bash
# 创建标签
git tag -a v1.0.0 -m "版本 1.0.0"
git push origin v1.0.0
```

然后在GitHub仓库的Releases页面创建新的发布。

## 📋 项目检查清单

- [ ] README.md 文档完整
- [ ] 所有功能测试通过
- [ ] 依赖包列表正确
- [ ] Git忽略文件配置正确
- [ ] 许可证文件已添加
- [ ] 配置文件示例已提供
- [ ] 代码注释清晰
- [ ] 错误处理完善

## 🔧 持续维护

### 更新依赖

```bash
# 更新requirements.txt
pip freeze > requirements.txt
```

### 添加新功能

1. 创建功能分支
2. 开发新功能
3. 测试功能
4. 提交并推送
5. 创建Pull Request

### 处理Issue

- 及时回复用户反馈
- 修复发现的bug
- 改进文档说明

## 📞 技术支持

- 在GitHub Issues中报告问题
- 提供详细的错误信息
- 包含复现步骤

## 🎯 最佳实践

1. **保持代码简洁** - 易于理解和维护
2. **完善文档** - 帮助用户快速上手
3. **测试充分** - 确保功能稳定
4. **及时更新** - 修复已知问题
5. **社区互动** - 积极回应用户反馈