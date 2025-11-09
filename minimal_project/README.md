# YouTube双语字幕生成工具

这是一个简洁的YouTube视频下载与双语字幕生成工具，可以将YouTube视频自动转换为带有中英双语字幕的视频。

## 功能特性

- ✅ **YouTube视频下载**: 自动下载YouTube视频和字幕
- ✅ **双语字幕生成**: 使用Deepseek LLM翻译英文字幕为中文
- ✅ **字幕烧录**: 将双语字幕直接烧录到视频画面中
- ✅ **智能跳过**: 检测已存在的文件，避免重复下载和翻译
- ✅ **Apple设备优化**: 针对Apple设备HD播放优化的视频编码

## 快速开始

### 1. 安装依赖
```bash
pip install yt-dlp openai
```

### 2. 安装ffmpeg
**macOS:** `brew install ffmpeg`  
**Ubuntu:** `sudo apt install ffmpeg`  
**Windows:** 下载ffmpeg并添加到PATH

### 3. 设置API密钥
```bash
export DEEPSEEK_API_KEY="sk-your-deepseek-api-key"
```

### 4. 运行工具
```bash
python youtube_downloader.py "youtube_url" output_folder
```

## 使用方法

```bash
# 基本用法
python youtube_downloader.py "https://youtu.be/your-video-id" output

# 使用API密钥参数
python youtube_downloader.py "https://youtu.be/your-video-id" output --deepseek-key "your-key"
```

## 字幕样式

- **字体**: Helvetica
- **字号**: 11（最小化，几乎不阻碍观看视线）
- **位置**: 底部，距离底部10像素
- **样式**: 白色文字，黑色边框，半透明背景

## 文件说明

- `youtube_downloader.py` - 主程序
- `youtube_bilingual_srt.py` - 字幕翻译模块
- `requirements.txt` - 依赖包列表
- `.gitignore` - Git忽略规则

## 许可证

MIT License