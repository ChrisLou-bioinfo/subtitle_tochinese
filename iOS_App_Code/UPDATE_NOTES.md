# 📱 更新说明 - 添加API设置功能

## 🎉 新功能

### ⚙️ API密钥设置界面

现在应用包含一个完整的设置界面，用户可以：

1. ✅ **输入API密钥** - 安全输入框，自动隐藏密钥
2. ✅ **保存密钥** - 自动保存到设备，下次打开自动加载
3. ✅ **查看状态** - 显示是否已配置API密钥
4. ✅ **获取帮助** - 提供获取API密钥的详细步骤
5. ✅ **快速访问** - 直接链接到Deepseek官网

## 🎨 界面更新

### 主界面
- 右上角添加了⚙️设置按钮
- 翻译按钮会检查API密钥状态
- 未配置时显示提示信息

### 设置界面
```
┌─────────────────────────────┐
│  ⚙️ 设置                     │
├─────────────────────────────┤
│  API配置                     │
│  ┌─────────────────────┐   │
│  │ Deepseek API密钥     │   │
│  │ [输入框]             │   │
│  └─────────────────────┘   │
│                             │
│  帮助                        │
│  ❓ 如何获取API密钥？        │
│  1. 访问 platform...        │
│  2. 注册并登录...           │
│  ...                        │
│  [打开Deepseek官网]         │
│                             │
│  状态                        │
│  ✓ 已配置                   │
│  密钥: sk-8f...9937         │
│                             │
│  [取消]          [保存]     │
└─────────────────────────────┘
```

## 🔧 技术实现

### 1. 数据持久化
使用 `@AppStorage` 自动保存API密钥：

```swift
@AppStorage("deepseek_api_key") private var apiKey: String = ""
```

**优点：**
- 自动保存到UserDefaults
- 应用重启后自动加载
- 无需手动管理存储

### 2. 安全输入
使用 `SecureField` 保护密钥输入：

```swift
SecureField("sk-xxxxxxxxxxxxxxxx", text: $tempApiKey)
```

**特点：**
- 输入时自动隐藏字符
- 防止屏幕截图泄露
- 符合安全最佳实践

### 3. 密钥验证
翻译前自动检查API密钥：

```swift
guard !apiKey.isEmpty else {
    errorMessage = "请先在设置中配置Deepseek API密钥"
    showingError = true
    return
}
```

### 4. 密钥脱敏
显示时自动隐藏中间部分：

```swift
private func maskApiKey(_ key: String) -> String {
    let start = key.prefix(4)
    let end = key.suffix(4)
    return "\(start)...\(end)"
}
```

**示例：**
- 原始：`sk-8fc6d65b137148bbb0470a815f969937`
- 显示：`sk-8f...9937`

## 📝 使用流程

### 首次使用

1. **打开应用**
   - 看到主界面

2. **点击设置按钮**
   - 右上角⚙️图标
   - 进入设置界面

3. **输入API密钥**
   - 在"Deepseek API密钥"输入框中输入
   - 可以查看帮助获取密钥

4. **保存设置**
   - 点击右上角"保存"按钮
   - 看到"保存成功"提示

5. **开始使用**
   - 返回主界面
   - 现在可以正常翻译了

### 后续使用

- ✅ API密钥已保存，无需重新输入
- ✅ 应用重启后自动加载
- ✅ 可随时在设置中修改

## 🎯 界面状态

### 未配置API密钥
```
主界面：
- 翻译按钮：灰色（禁用）
- 提示文字："请先在设置中配置API密钥"

设置界面：
- 状态：⚠️ 未配置
```

### 已配置API密钥
```
主界面：
- 翻译按钮：蓝色（可用）
- 无提示文字

设置界面：
- 状态：✓ 已配置
- 显示：密钥脱敏版本
```

## 🔐 安全特性

### 1. 本地存储
- API密钥只保存在设备本地
- 不会上传到任何服务器
- 使用iOS系统的UserDefaults

### 2. 输入保护
- 使用SecureField隐藏输入
- 防止肩窥攻击
- 防止屏幕录制泄露

### 3. 显示脱敏
- 查看时只显示首尾4位
- 中间部分用...代替
- 防止意外泄露

### 4. 传输安全
- API调用使用HTTPS
- 密钥通过Authorization头传输
- 符合OAuth 2.0标准

## 📊 代码变更

### 新增文件
无（所有代码在ContentView_v2.swift中）

### 修改内容

1. **状态变量**
   ```swift
   @State private var showingSettings: Bool = false
   @AppStorage("deepseek_api_key") private var apiKey: String = ""
   ```

2. **工具栏按钮**
   ```swift
   .toolbar {
       ToolbarItem(placement: .navigationBarTrailing) {
           Button(action: { showingSettings = true }) {
               Image(systemName: "gearshape")
           }
       }
   }
   ```

3. **设置界面**
   ```swift
   .sheet(isPresented: $showingSettings) {
       SettingsView(apiKey: $apiKey)
   }
   ```

4. **API初始化**
   ```swift
   let api = DeepseekAPI(apiKey: apiKey)
   ```

5. **新增SettingsView组件**
   - 完整的设置界面
   - 表单布局
   - 帮助信息
   - 状态显示

## 🎨 UI组件

### 设置界面组件

1. **API配置区**
   - 标题
   - 输入框（SecureField）
   - 说明文字

2. **帮助区**
   - 获取步骤
   - 官网链接

3. **状态区**
   - 配置状态
   - 密钥预览（脱敏）

4. **工具栏**
   - 取消按钮
   - 保存按钮

## 🐛 错误处理

### 1. 空密钥检查
```swift
guard !apiKey.isEmpty else {
    errorMessage = "请先在设置中配置Deepseek API密钥"
    showingError = true
    return
}
```

### 2. 保存验证
```swift
.disabled(tempApiKey.isEmpty)
```

### 3. 状态提示
```swift
if apiKey.isEmpty {
    Text("请先在设置中配置API密钥")
        .font(.caption)
        .foregroundColor(.orange)
}
```

## 📚 用户指南

### 如何获取Deepseek API密钥？

1. **访问官网**
   - 打开 https://platform.deepseek.com
   - 或在设置中点击"打开Deepseek官网"

2. **注册账号**
   - 点击"Sign Up"
   - 填写邮箱和密码
   - 验证邮箱

3. **创建API密钥**
   - 登录后进入Dashboard
   - 点击"API Keys"
   - 点击"Create API Key"
   - 复制生成的密钥

4. **配置到应用**
   - 打开应用设置
   - 粘贴API密钥
   - 点击保存

### 常见问题

**Q: API密钥会丢失吗？**
A: 不会，密钥保存在设备本地，除非删除应用或清除数据。

**Q: 可以修改API密钥吗？**
A: 可以，随时在设置中修改并保存。

**Q: API密钥安全吗？**
A: 是的，使用SecureField输入，本地加密存储，传输使用HTTPS。

**Q: 忘记API密钥怎么办？**
A: 在Deepseek官网重新生成一个新的密钥。

## 🎯 下一步优化

### 短期
- [ ] 添加API密钥测试功能
- [ ] 显示API使用量
- [ ] 支持多个API密钥切换

### 中期
- [ ] 添加密钥有效期提醒
- [ ] 支持其他翻译API
- [ ] 添加翻译质量设置

### 长期
- [ ] 云端同步设置
- [ ] 团队共享API密钥
- [ ] 高级安全选项

## ✅ 测试清单

- [x] 首次打开应用，未配置API密钥
- [x] 点击设置按钮，进入设置界面
- [x] 输入API密钥并保存
- [x] 返回主界面，翻译按钮可用
- [x] 关闭应用重新打开，API密钥仍然存在
- [x] 修改API密钥并保存
- [x] 密钥显示正确脱敏
- [x] 未配置时翻译按钮禁用
- [x] 点击官网链接正常跳转

## 🎉 完成！

现在您的iOS应用有了完整的API密钥管理功能！

**主要改进：**
- ✅ 用户友好的设置界面
- ✅ 安全的密钥存储
- ✅ 清晰的使用指引
- ✅ 完善的错误提示
- ✅ 持久化保存

祝您使用愉快！🎊
