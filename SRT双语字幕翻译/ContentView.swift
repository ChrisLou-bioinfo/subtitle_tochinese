//
//  ContentView.swift
//  SRT双语字幕翻译
//
//  SRT字幕翻译工具 - iOS版本
//  上传英文SRT字幕，翻译成双语字幕并下载
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    // MARK: - 状态变量
    @State private var isProcessing: Bool = false
    @State private var progress: Double = 0.0
    @State private var statusMessage: String = "请选择SRT字幕文件"
    @State private var subtitles: [SubtitleBlock] = []
    @State private var showingSubtitles: Bool = false
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false
    @State private var showingFilePicker: Bool = false
    @State private var selectedFileName: String = ""
    @State private var bilingualSRTContent: String = ""
    @State private var showingShareSheet: Bool = false
    @State private var showingAppInfo: Bool = false
    
    // MARK: - 主界面
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 标题
                    headerView
                    
                    // 文件选择区域
                    filePickerView
                    
                    // 翻译按钮
                    if !selectedFileName.isEmpty && !isProcessing {
                        translateButtonView
                    }
                    
                    // 进度显示
                    if isProcessing {
                        progressView
                    }
                    
                    // 状态信息
                    statusView
                    
                    // 操作按钮组
                    if !subtitles.isEmpty && !bilingualSRTContent.isEmpty {
                        actionButtonsView
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("SRT双语字幕翻译")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAppInfo = true }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType(filenameExtension: "srt")!],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .sheet(isPresented: $showingSubtitles) {
                SubtitleListView(subtitles: subtitles)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = saveBilingualSRT() {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showingAppInfo) {
                AppInfoView()
            }
            .alert("错误", isPresented: $showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - 子视图组件
    
    /// 标题视图
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.fill.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("SRT双语字幕翻译")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("上传英文字幕，生成双语字幕")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    /// 文件选择视图
    private var filePickerView: some View {
        VStack(spacing: 15) {
            Button(action: { showingFilePicker = true }) {
                VStack(spacing: 12) {
                    Image(systemName: selectedFileName.isEmpty ? "doc.badge.plus" : "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundColor(selectedFileName.isEmpty ? .gray : .blue)
                    
                    if selectedFileName.isEmpty {
                        Text("点击选择SRT字幕文件")
                            .font(.headline)
                            .foregroundColor(.primary)
                    } else {
                        VStack(spacing: 4) {
                            Text("已选择文件")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(selectedFileName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                        )
                )
            }
            .disabled(isProcessing)
            
            Text("支持 .srt 格式的英文字幕文件")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// 翻译按钮视图
    private var translateButtonView: some View {
        VStack(spacing: 8) {
            Button(action: startProcessing) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("开始翻译")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
    }
    
    /// 进度视图
    private var progressView: some View {
        VStack(spacing: 10) {
            ProgressView(value: progress, total: 100)
                .progressViewStyle(.linear)
            
            Text("\(Int(progress))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// 状态视图
    private var statusView: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(statusMessage)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    /// 操作按钮组视图
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            // 查看字幕按钮
            Button(action: { showingSubtitles = true }) {
                HStack {
                    Image(systemName: "text.bubble")
                    Text("查看双语字幕")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            
            // 下载字幕按钮
            Button(action: { showingShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("下载双语字幕")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var statusIcon: String {
        if isProcessing {
            return "arrow.triangle.2.circlepath"
        } else if !bilingualSRTContent.isEmpty {
            return "checkmark.circle.fill"
        } else if !selectedFileName.isEmpty {
            return "doc.text"
        } else {
            return "info.circle"
        }
    }
    
    private var statusColor: Color {
        if isProcessing {
            return .blue
        } else if !bilingualSRTContent.isEmpty {
            return .green
        } else {
            return .gray
        }
    }
    
    // MARK: - 核心功能
    
    /// 处理文件选择结果
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        do {
            let fileURL = try result.get().first
            guard let url = fileURL else { return }
            
            // 开始访问安全作用域资源
            guard url.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "FileAccess", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法访问文件"])
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            // 读取文件内容
            let content = try String(contentsOf: url, encoding: .utf8)
            
            // 解析SRT文件
            let parsedSubtitles = parseSRT(content: content)
            
            if parsedSubtitles.isEmpty {
                throw NSError(domain: "SRTParse", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析SRT文件，请确保文件格式正确"])
            }
            
            // 保存文件名和字幕数据
            selectedFileName = url.lastPathComponent
            subtitles = parsedSubtitles
            bilingualSRTContent = "" // 重置双语字幕内容
            updateStatus("已加载 \(parsedSubtitles.count) 条字幕，点击开始翻译")
            
        } catch {
            errorMessage = "文件读取失败: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    /// 开始翻译处理
    private func startProcessing() {
        isProcessing = true
        progress = 0
        updateStatus("开始翻译字幕...")
        
        // 模拟翻译过程
        DispatchQueue.global(qos: .userInitiated).async {
            var translatedSubtitles: [SubtitleBlock] = []
            
            for (index, subtitle) in subtitles.enumerated() {
                DispatchQueue.main.async {
                    progress = Double(index) / Double(subtitles.count) * 100
                    updateStatus("正在翻译第 \(index + 1)/\(subtitles.count) 条字幕...")
                }
                
                // 模拟翻译延迟
                Thread.sleep(forTimeInterval: 0.1)
                
                // 使用内置翻译功能
                let translatedText = translateText(subtitle.text)
                let bilingualSubtitle = SubtitleBlock(
                    id: subtitle.id,
                    startTime: subtitle.startTime,
                    endTime: subtitle.endTime,
                    text: subtitle.text,
                    translatedText: translatedText
                )
                translatedSubtitles.append(bilingualSubtitle)
            }
            
            DispatchQueue.main.async {
                subtitles = translatedSubtitles
                bilingualSRTContent = generateBilingualSRT(subtitles: translatedSubtitles)
                progress = 100
                isProcessing = false
                updateStatus("翻译完成！共翻译 \(translatedSubtitles.count) 条字幕")
            }
        }
    }
    
    /// 更新状态信息
    private func updateStatus(_ message: String) {
        statusMessage = message
    }
    
    /// 保存双语SRT文件
    private func saveBilingualSRT() -> URL? {
        let fileName = selectedFileName.replacingOccurrences(of: ".srt", with: "_双语.srt")
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try bilingualSRTContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            errorMessage = "文件保存失败: \(error.localizedDescription)"
            showingError = true
            return nil
        }
    }
}

// MARK: - SRT解析和生成功能

/// 字幕块结构
struct SubtitleBlock: Identifiable {
    let id: Int
    let startTime: String
    let endTime: String
    let text: String
    var translatedText: String = ""
}

/// 解析SRT文件内容
func parseSRT(content: String) -> [SubtitleBlock] {
    var subtitles: [SubtitleBlock] = []
    let lines = content.components(separatedBy: .newlines)
    var currentId: Int = 0
    var currentStartTime: String = ""
    var currentEndTime: String = ""
    var currentText: String = ""
    
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        if trimmedLine.isEmpty {
            // 空行表示一个字幕块结束
            if currentId > 0 && !currentStartTime.isEmpty && !currentText.isEmpty {
                let subtitle = SubtitleBlock(
                    id: currentId,
                    startTime: currentStartTime,
                    endTime: currentEndTime,
                    text: currentText
                )
                subtitles.append(subtitle)
                
                // 重置变量
                currentId = 0
                currentStartTime = ""
                currentEndTime = ""
                currentText = ""
            }
        } else if currentId == 0 && Int(trimmedLine) != nil {
            // 字幕序号
            currentId = Int(trimmedLine) ?? 0
        } else if currentStartTime.isEmpty && trimmedLine.contains(" --> ") {
            // 时间轴
            let timeComponents = trimmedLine.components(separatedBy: " --> ")
            if timeComponents.count == 2 {
                currentStartTime = timeComponents[0].trimmingCharacters(in: .whitespaces)
                currentEndTime = timeComponents[1].trimmingCharacters(in: .whitespaces)
            }
        } else if currentId > 0 {
            // 字幕文本
            if !currentText.isEmpty {
                currentText += "\n"
            }
            currentText += trimmedLine
        }
    }
    
    // 处理最后一个字幕块
    if currentId > 0 && !currentStartTime.isEmpty && !currentText.isEmpty {
        let subtitle = SubtitleBlock(
            id: currentId,
            startTime: currentStartTime,
            endTime: currentEndTime,
            text: currentText
        )
        subtitles.append(subtitle)
    }
    
    return subtitles
}

/// 内置翻译功能
func translateText(_ text: String) -> String {
    // 简单的内置翻译字典
    let translationDict: [String: String] = [
        "hello": "你好",
        "world": "世界",
        "thank you": "谢谢",
        "good": "好",
        "bad": "坏",
        "yes": "是",
        "no": "不",
        "please": "请",
        "sorry": "对不起",
        "excuse me": "打扰一下",
        "how are you": "你好吗",
        "fine": "很好",
        "ok": "好的",
        "understand": "理解",
        "help": "帮助",
        "problem": "问题",
        "solution": "解决方案",
        "time": "时间",
        "day": "天",
        "night": "晚上",
        "morning": "早上",
        "evening": "傍晚"
    ]
    
    var translated = text.lowercased()
    
    // 简单的单词替换翻译
    for (english, chinese) in translationDict {
        translated = translated.replacingOccurrences(of: english, with: chinese)
    }
    
    return translated.isEmpty ? "[翻译内容]" : translated
}

/// 生成双语SRT内容
func generateBilingualSRT(subtitles: [SubtitleBlock]) -> String {
    var srtContent = ""
    
    for subtitle in subtitles {
        srtContent += "\(subtitle.id)\n"
        srtContent += "\(subtitle.startTime) --> \(subtitle.endTime)\n"
        srtContent += "\(subtitle.text)\n"
        if !subtitle.translatedText.isEmpty {
            srtContent += "\(subtitle.translatedText)\n"
        }
        srtContent += "\n"
    }
    
    return srtContent
}

// MARK: - 辅助视图

/// 字幕列表视图
struct SubtitleListView: View {
    let subtitles: [SubtitleBlock]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(subtitles) { subtitle in
                VStack(alignment: .leading, spacing: 8) {
                    Text("第\(subtitle.id)条")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(subtitle.text)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if !subtitle.translatedText.isEmpty {
                        Text(subtitle.translatedText)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    
                    Text("\(subtitle.startTime) - \(subtitle.endTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("双语字幕预览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 应用信息视图
struct AppInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 应用信息
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SRT双语字幕翻译")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("版本 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("一款简单易用的SRT字幕翻译工具，支持英文字幕翻译成双语字幕。")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    // 功能特点
                    VStack(alignment: .leading, spacing: 12) {
                        Text("功能特点")
                            .font(.headline)
                        
                        FeatureRow(icon: "doc.badge.plus", text: "支持SRT格式字幕文件")
                        FeatureRow(icon: "wand.and.stars", text: "内置翻译功能")
                        FeatureRow(icon: "text.bubble", text: "双语字幕预览")
                        FeatureRow(icon: "square.and.arrow.down", text: "一键下载双语字幕")
                    }
                    
                    Divider()
                    
                    // 使用说明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("使用说明")
                            .font(.headline)
                        
                        InstructionStep(number: 1, text: "点击选择SRT字幕文件")
                        InstructionStep(number: 2, text: "点击开始翻译按钮")
                        InstructionStep(number: 3, text: "等待翻译完成")
                        InstructionStep(number: 4, text: "预览或下载双语字幕")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("应用信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 功能特点行
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

/// 使用步骤
struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

/// 分享视图
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}

// MARK: - 预览

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}