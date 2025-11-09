# 📱 iOS应用代码使用说明

## 🎯 这个文件夹包含什么？

这里是完整的iOS应用代码，可以直接复制到Xcode项目中使用。

## 📋 文件说明

- **ContentView.swift** - 主界面和核心逻辑（完整可用）
- 包含所有必要的功能：
  - ✅ UI界面
  - ✅ YouTube链接输入
  - ✅ Deepseek API集成
  - ✅ 字幕翻译功能
  - ✅ 双语字幕显示

## 🚀 如何使用

### 方法1：创建新项目（推荐）

1. **打开Xcode**
2. **创建新项目**
   - File → New → Project
   - 选择 iOS → App
   - Product Name: `YouTubeSubtitleApp`
   - Interface: SwiftUI
   - Language: Swift

3. **替换代码**
   - 打开项目中的 `ContentView.swift`
   - 删除所有默认代码
   - 复制粘贴 `iOS_App_Code/ContentView.swift` 的全部内容

4. **运行**
   - 连接iPhone
   - 点击运行按钮（▶️）

### 方法2：直接导入文件

1. 在Xcode中右键点击项目
2. 选择 "Add Files to..."
3. 选择 `ContentView.swift` 文件
4. 确保勾选 "Copy items if needed"

## ⚙️ 配置API密钥

在 `ContentView.swift` 中找到这一行：

```swift
private let apiKey = "sk-8fc6d65b137148bbb0470a815f969937"
```

替换为您自己的Deepseek API密钥。

## 📱 在iPhone上运行

### 首次运行步骤：

1. **连接iPhone到Mac**
   - 使用USB线连接
   - 解锁iPhone
   - 点击"信任"

2. **选择设备**
   - Xcode顶部：选择您的iPhone

3. **运行应用**
   - 点击 ▶️ 按钮
   - 或按 Cmd+R

4. **信任开发者**（首次需要）
   - iPhone：设置 → 通用 → VPN与设备管理
   - 找到您的开发者账号
   - 点击"信任"

5. **重新运行**
   - 返回Xcode
   - 再次点击运行

## 🎨 当前功能

### ✅ 已实现
- 美观的UI界面
- YouTube链接输入
- Deepseek API翻译
- 双语字幕显示
- 进度显示
- 错误处理

### 🚧 待实现（需要额外开发）
- 真实的YouTube字幕下载
- 视频下载功能
- 字幕烧录功能
- 视频播放功能

## 💡 代码说明

### 主要组件

1. **ContentView** - 主界面
   - 包含所有UI元素
   - 处理用户交互

2. **SubtitleBlock** - 字幕数据模型
   - 存储字幕信息
   - 包含英文和中文文本

3. **DeepseekAPI** - API服务类
   - 调用Deepseek翻译API
   - 处理网络请求

4. **SubtitleListView** - 字幕列表视图
   - 显示双语字幕
   - 支持滚动查看

### 代码特点

- ✅ 完整的注释说明
- ✅ 清晰的代码结构
- ✅ 错误处理机制
- ✅ 异步处理（async/await）
- ✅ 现代SwiftUI设计

## 🔧 常见问题

### Q: 编译错误怎么办？
A: 确保：
- Xcode版本 ≥ 14.0
- iOS部署目标 ≥ 15.0
- 已选择正确的开发团队

### Q: 无法在iPhone上运行？
A: 检查：
- iPhone已连接并解锁
- 已信任开发者证书
- Xcode中选择了正确的设备

### Q: API调用失败？
A: 确认：
- API密钥正确
- 网络连接正常
- iPhone允许网络访问

## 📚 学习资源

### 推荐学习路径

1. **SwiftUI基础**
   - Apple官方教程：https://developer.apple.com/tutorials/swiftui
   - 100 Days of SwiftUI（免费）

2. **网络请求**
   - URLSession文档
   - Async/Await教程

3. **iOS开发**
   - Hacking with Swift
   - Ray Wenderlich教程

## 🎯 下一步开发

### 短期目标（1-2周）
1. 实现真实的YouTube字幕下载
2. 添加视频信息显示
3. 优化UI体验

### 中期目标（1个月）
1. 添加视频下载功能
2. 实现本地存储
3. 添加历史记录

### 长期目标（2-3个月）
1. 实现字幕烧录
2. 添加视频播放器
3. 准备App Store上架

## 💬 需要帮助？

如果遇到问题：
1. 检查Xcode控制台的错误信息
2. 确认所有步骤都正确执行
3. 查看代码注释了解详细说明

祝您开发顺利！🎉
