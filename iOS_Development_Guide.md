# 📱 YouTube双语字幕工具 - iOS/macOS App 开发指南

## 🎯 项目目标
将Python命令行工具转换为iOS和macOS原生应用

## 📊 技术架构

### 方案选择
由于核心功能（yt-dlp、ffmpeg）是Python实现，我们有两个方案：

#### 方案A：纯原生Swift应用（推荐）
- **优点**：性能好、用户体验佳、可上架App Store
- **缺点**：需要重写核心逻辑
- **技术栈**：SwiftUI + URLSession + AVFoundation

#### 方案B：混合应用（Python后端 + Swift前端）
- **优点**：复用现有Python代码
- **缺点**：无法上架App Store、体积大
- **技术栈**：SwiftUI + Python（通过PythonKit）

**建议：采用方案A，使用纯Swift重写核心功能**

---

## 🚀 第一步：创建Xcode项目

### 1.1 打开Xcode
1. 打开Xcode应用
2. 选择 "Create a new Xcode project"

### 1.2 选择项目模板
1. 选择 **iOS** → **App**
2. 点击 "Next"

### 1.3 配置项目信息
- **Product Name**: `YouTubeSubtitleApp`
- **Team**: 选择您的开发者账号
- **Organization Identifier**: `com.yourname` (例如：com.chris)
- **Bundle Identifier**: 自动生成（例如：com.chris.YouTubeSubtitleApp）
- **Interface**: 选择 **SwiftUI**
- **Language**: 选择 **Swift**
- **Storage**: 选择 **None**
- **勾选**: Include Tests（可选）

### 1.4 选择保存位置
选择一个文件夹保存项目（建议保存在您的工作目录）

---

## 🎨 第二步：设计应用界面

### 2.1 应用功能规划
- ✅ 输入YouTube链接
- ✅ 选择输出质量（HD/标清）
- ✅ 显示下载进度
- ✅ 显示翻译进度
- ✅ 播放/分享最终视频

### 2.2 界面设计草图
```
┌─────────────────────────────┐
│  YouTube双语字幕工具         │
├─────────────────────────────┤
│                             │
│  [输入YouTube链接]           │
│  ┌─────────────────────┐   │
│  │ https://youtu.be/... │   │
│  └─────────────────────┘   │
│                             │
│  视频质量: [HD ▼]            │
│                             │
│  [开始下载和翻译]            │
│                             │
│  进度: ████████░░ 80%       │
│                             │
│  状态: 正在翻译字幕...       │
│                             │
│  [查看视频] [分享]           │
│                             │
└─────────────────────────────┘
```

---

## 💻 第三步：核心功能实现

### 3.1 需要实现的功能模块

#### A. YouTube视频下载
**挑战**：iOS不能直接使用yt-dlp
**解决方案**：
1. 使用YouTube Data API获取视频信息
2. 使用第三方库（如youtube-ios）
3. 或者搭建自己的后端服务器

#### B. 字幕下载和解析
**实现方式**：
- 使用URLSession下载字幕文件
- 解析SRT格式（纯文本解析）

#### C. 翻译功能
**实现方式**：
- 调用Deepseek API（与Python版本相同）
- 使用URLSession发送HTTP请求

#### D. 字幕烧录
**挑战**：iOS不能直接使用ffmpeg
**解决方案**：
1. 使用AVFoundation框架
2. 或者使用编译好的ffmpeg iOS库
3. 或者后端服务器处理

---

## 🔧 第四步：最简化MVP方案

### 推荐：先做一个最小可行产品（MVP）

**MVP功能**：
1. ✅ 输入YouTube链接
2. ✅ 下载字幕文件
3. ✅ 调用Deepseek API翻译
4. ✅ 显示双语字幕
5. ❌ 暂不实现视频下载和烧录（太复杂）

**后续扩展**：
- 添加视频下载功能
- 添加字幕烧录功能
- 优化用户体验

---

## 📝 第五步：代码实现示例

### 5.1 创建数据模型

```swift
// Models/SubtitleBlock.swift
struct SubtitleBlock: Identifiable {
    let id = UUID()
    let index: Int
    let timeline: String
    let englishText: String
    var chineseText: String = ""
}
```

### 5.2 创建API服务

```swift
// Services/DeepseekAPI.swift
import Foundation

class DeepseekAPI {
    private let apiKey = "your-api-key"
    private let baseURL = "https://api.deepseek.com"
    
    func translate(text: String) async throws -> String {
        // 实现翻译逻辑
    }
}
```

### 5.3 创建主界面

```swift
// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var youtubeURL = ""
    @State private var isProcessing = false
    @State private var progress = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("YouTube双语字幕工具")
                .font(.title)
            
            TextField("输入YouTube链接", text: $youtubeURL)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("开始处理") {
                processVideo()
            }
            .disabled(isProcessing)
            
            if isProcessing {
                ProgressView(value: progress)
                    .padding()
            }
        }
        .padding()
    }
    
    func processVideo() {
        // 实现处理逻辑
    }
}
```

---

## 🎯 第六步：在iPhone上运行

### 6.1 连接iPhone
1. 用USB线连接iPhone到Mac
2. 在iPhone上信任这台电脑

### 6.2 配置开发者账号
1. Xcode → Preferences → Accounts
2. 添加您的Apple ID
3. 下载开发者证书

### 6.3 选择设备并运行
1. 在Xcode顶部选择您的iPhone设备
2. 点击运行按钮（▶️）
3. 首次运行需要在iPhone上信任开发者：
   - 设置 → 通用 → VPN与设备管理
   - 信任您的开发者账号

---

## ⚠️ 重要注意事项

### iOS限制
1. **后台下载限制**：iOS对后台任务有严格限制
2. **文件系统限制**：只能访问应用沙盒
3. **网络限制**：需要处理App Transport Security
4. **存储限制**：视频文件会占用大量空间

### 建议的实现方式
**最佳方案：前端iOS App + 后端服务器**
- iOS App：负责UI和用户交互
- 后端服务器：运行您的Python代码
- 优点：复用现有代码、绕过iOS限制
- 缺点：需要维护服务器

---

## 📚 学习资源

### Swift和SwiftUI入门
1. Apple官方教程：[SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
2. 100 Days of SwiftUI（免费课程）
3. Hacking with Swift（免费教程）

### iOS开发基础
1. URLSession网络请求
2. AVFoundation视频处理
3. FileManager文件管理

---

## 🚀 快速开始建议

### 立即可以做的事情：
1. ✅ 创建Xcode项目
2. ✅ 设计基本UI界面
3. ✅ 实现字幕下载功能
4. ✅ 实现Deepseek API调用
5. ✅ 显示双语字幕

### 需要更多时间的功能：
1. ⏰ 视频下载（需要研究YouTube API或第三方库）
2. ⏰ 字幕烧录（需要学习AVFoundation或集成ffmpeg）
3. ⏰ 后端服务器（如果选择混合方案）

---

## 💡 我的建议

**第一阶段（1-2周）**：
- 学习SwiftUI基础
- 创建简单的UI界面
- 实现字幕下载和翻译功能

**第二阶段（2-4周）**：
- 添加视频下载功能
- 优化用户体验
- 添加错误处理

**第三阶段（长期）**：
- 实现字幕烧录
- 添加更多功能
- 准备上架App Store

---

## 🎯 下一步行动

1. **现在就做**：打开Xcode，创建第一个项目
2. **今天学习**：完成Apple官方SwiftUI教程第一课
3. **本周目标**：实现基本UI界面
4. **下周目标**：实现字幕下载功能

准备好了吗？让我们开始创建您的第一个iOS应用！
