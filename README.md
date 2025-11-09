# YouTube双语字幕生成工具

这是一个完整的YouTube视频下载、字幕翻译和视频合并工具，可以将YouTube视频自动转换为带有中英双语字幕的视频。

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/youtube-bilingual-subtitles.git
cd youtube-bilingual-subtitles
```

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

### 3. 安装ffmpeg (视频处理需要)

**macOS:**

```bash
brew install ffmpeg
```

**Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install ffmpeg
```

**Windows:** 下载ffmpeg并添加到PATH环境变量

### 4. 设置Deepseek API密钥

有三种方式设置API密钥：

#### 方式1: 环境变量

```bash
export DEEPSEEK_API_KEY="sk-your-deepseek-api-key"
```

#### 方式2: 命令行参数

```bash
python youtube_downloader.py "https://www.youtube.com/watch?v=your-video-id" output_folder --deepseek-key "sk-your-deepseek-api-key"
```

#### 方式3: 创建配置文件

```bash
cp .env.example .env
# 编辑 .env 文件，填入您的Deepseek API密钥
```

### 5. 运行工具

```bash
python youtube_downloader.py "https://www.youtube.com/watch?v=your-video-id" output_folder
```

## 功能特性

- ✅ **YouTube视频下载**: 自动下载YouTube视频和字幕
- ✅ **双语字幕生成**: 使用Deepseek LLM翻译英文字幕为中文
- ✅ **字幕烧录**: 将双语字幕直接烧录到视频画面中（无需手动选择字幕）
- ✅ **Apple设备优化**: 针对Apple设备HD播放优化的视频编码
- ✅ **批量处理**: 支持多个视频的批量处理
- ✅ **进度跟踪**: 详细的进度显示和错误处理

### 字幕烧录功能

字幕会直接嵌入到视频画面中，具有以下特点：
- **自动显示**: 无需手动开启字幕选项
- **兼容性好**: 在任何播放器上都能正常显示
- **美观样式**: 白色文字，黑色边框，半透明背景
- **精确定位**: 位于视频底部，不会遮挡重要内容

### 字幕样式

烧录的字幕使用以下样式：
- **字体**: Helvetica
- **字号**: 11（最小化，几乎不阻碍观看视线）
- **颜色**: 白色文字，黑色边框
- **位置**: 底部，距离底部10像素
- **背景**: 半透明黑色背景

字幕会直接显示在视频画面上，无需手动开启，适合在各种播放器上观看。

## 安装依赖

```bash
pip install yt-dlp openai
```

### 安装ffmpeg (视频合并需要)

**macOS:**

```bash
brew install ffmpeg
```

**Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install ffmpeg
```

**Windows:**
下载ffmpeg并添加到PATH环境变量

## 使用方法

### 运行完整流程

```bash
python youtube_downloader.py "https://www.youtube.com/watch?v=your-video-id" output_folder
```

### API密钥设置说明

有三种方式设置Deepseek API密钥：

#### 方法一: 环境变量

```bash
export DEEPSEEK_API_KEY="sk-your-deepseek-api-key"
```

#### 方法二: 命令行参数

```bash
python youtube_downloader.py "https://www.youtube.com/watch?v=your-video-id" output_folder --deepseek-key "sk-your-deepseek-api-key"
```

#### 方法三: 配置文件

```bash
echo "DEEPSEEK_API_KEY=sk-your-deepseek-api-key" > .env
```

### 获取Deepseek API密钥

1. 访问 [Deepseek官网](https://platform.deepseek.com/)
2. 注册账号并登录
3. 在API密钥管理页面创建新的API密钥
4. 将生成的密钥替换到上述命令中

### 3. 仅下载视频和字幕

```bash
python youtube_downloader.py "youtube_url" output_folder --skip-translation
```

### 4. 仅翻译现有字幕

```bash
python youtube_bilingual_srt.py "youtube_url" output_folder
```

## 文件说明

- `youtube_downloader.py` - 主程序，完整的视频下载+翻译+合并流程
- `youtube_bilingual_srt.py` - 仅生成双语字幕
- `bilingual_srt_improved.py` - 字幕翻译核心模块
- `deepseek_client.py` - Deepseek API客户端

## 输出文件结构

处理完成后，输出文件夹将包含：

```bash
output_folder/
├── video_title.mp4              # 原始视频文件
├── video_title.en.srt           # 原始英文字幕
├── video_title_bilingual.srt    # 双语字幕文件
└── video_title_with_subtitles.mp4  # 带字幕的最终视频
```

## 配置选项

### 视频质量设置

在 `youtube_downloader.py` 中修改 `format` 参数：

```python
'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'
```

### 字幕语言设置

修改 `subtitleslangs` 参数选择其他语言：

```python
'subtitleslangs': ['en', 'zh', 'ja']  # 下载多种语言字幕
```

## 故障排除

### 常见问题

1. **ffmpeg未找到**
   - 解决方案：安装ffmpeg并确保在PATH中

2. **Deepseek API错误**
   - 检查API密钥是否正确
   - 确认API配额充足

3. **YouTube下载失败**
   - 检查网络连接
   - 确认视频URL有效
   - 尝试使用VPN

4. **字幕翻译质量差**
   - 检查原始字幕质量
   - 尝试调整翻译提示词

### 调试模式

启用详细日志：

```bash
python youtube_downloader.py "youtube_url" output_folder --verbose
```

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request来改进这个工具！
