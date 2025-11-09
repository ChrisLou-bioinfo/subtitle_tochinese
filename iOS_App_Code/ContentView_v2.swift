//
//  ContentView.swift
//  SRTTranslatorApp
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
    @State private var showingSettings: Bool = false
    
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
            .navigationTitle("SRT字幕翻译")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
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
            .sheet(isPresented: $showingSettings) {
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
            
            Text("SRT字幕翻译工具")
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
        Task {
            await translateSubtitles()
        }
    }
    
    /// 翻译字幕的主要流程
    private func translateSubtitles() async {
        isProcessing = true
        progress = 0
        
        do {
            updateStatus("开始翻译字幕...")
            progress = 10
            
            var translatedSubtitles = subtitles
            
            for (index, subtitle) in subtitles.enumerated() {
                updateStatus("翻译中... (\(index + 1)/\(subtitles.count))")
                
                // 使用内置的简单翻译功能
                let translation = simpleTranslate(text: subtitle.englishText)
                translatedSubtitles[index].chineseText = translation
                
                // 更新进度
                let currentProgress = 10 + (Double(index + 1) / Double(subtitles.count) * 90)
                progress = currentProgress
                
                // 添加小延迟避免UI卡顿
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            
            // 更新字幕数据
            subtitles = translatedSubtitles
            
            // 生成双语SRT内容
            bilingualSRTContent = buildBilingualSRT(subtitles: translatedSubtitles)
            
            progress = 100
            updateStatus("翻译完成！共 \(subtitles.count) 条字幕")
            
        } catch {
            errorMessage = "翻译失败: \(error.localizedDescription)"
            showingError = true
            updateStatus("翻译失败")
        }
        
        isProcessing = false
    }
    
    /// 解析SRT文件
    private func parseSRT(content: String) -> [SubtitleBlock] {
        var blocks: [SubtitleBlock] = []
        let lines = content.components(separatedBy: .newlines)
        
        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            
            // 检查是否是数字索引
            if let index = Int(line) {
                var timeline = ""
                var textLines: [String] = []
                
                // 读取时间轴
                i += 1
                if i < lines.count {
                    let timeLine = lines[i].trimmingCharacters(in: .whitespaces)
                    if timeLine.contains("-->") {
                        timeline = timeLine
                        i += 1
                    }
                }
                
                // 读取文本内容
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).isEmpty {
                    textLines.append(lines[i].trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                
                if !textLines.isEmpty {
                    let text = textLines.joined(separator: " ")
                    blocks.append(SubtitleBlock(
                        index: index,
                        timeline: timeline,
                        englishText: text,
                        chineseText: ""
                    ))
                }
            }
            
            i += 1
        }
        
        return blocks
    }
    
    /// 构建双语SRT内容
    private func buildBilingualSRT(subtitles: [SubtitleBlock]) -> String {
        var result: [String] = []
        
        for subtitle in subtitles {
            result.append("\(subtitle.index)")
            result.append(subtitle.timeline)
            result.append(subtitle.englishText)
            if !subtitle.chineseText.isEmpty {
                result.append(subtitle.chineseText)
            }
            result.append("")
        }
        
        return result.joined(separator: "\n")
    }
    
    /// 保存双语SRT文件
    private func saveBilingualSRT() -> URL? {
        let fileName = selectedFileName.replacingOccurrences(of: ".srt", with: "_bilingual.srt")
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try bilingualSRTContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            errorMessage = "保存文件失败: \(error.localizedDescription)"
            showingError = true
            return nil
        }
    }
    
    /// 更新状态消息
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            statusMessage = message
        }
    }
    
    /// 简单的内置翻译功能
    private func simpleTranslate(text: String) -> String {
        // 这是一个简单的演示翻译功能
        // 在实际应用中，您可以考虑使用免费的翻译API或更复杂的逻辑
        let translations: [String: String] = [
            "hello": "你好",
            "world": "世界",
            "thank you": "谢谢",
            "goodbye": "再见",
            "please": "请",
            "sorry": "对不起",
            "yes": "是",
            "no": "不",
            "ok": "好的",
            "help": "帮助"
        ]
        
        // 简单的关键词匹配翻译
        let lowercasedText = text.lowercased()
        for (english, chinese) in translations {
            if lowercasedText.contains(english) {
                return chinese
            }
        }
        
        // 如果没有匹配，返回原始文本
        return "[翻译: " + text + "]"
    }
}

// MARK: - 数据模型

/// 字幕块数据结构
struct SubtitleBlock: Identifiable {
    let id = UUID()
    let index: Int
    let timeline: String
    let englishText: String
    var chineseText: String
}

// MARK: - 字幕列表视图

/// 显示双语字幕列表
struct SubtitleListView: View {
    let subtitles: [SubtitleBlock]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(subtitles) { subtitle in
                VStack(alignment: .leading, spacing: 8) {
                    // 时间轴
                    Text(subtitle.timeline)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 英文字幕
                    Text(subtitle.englishText)
                        .font(.body)
                    
                    // 中文字幕
                    if !subtitle.chineseText.isEmpty {
                        Text(subtitle.chineseText)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("双语字幕")
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

// MARK: - 分享视图

/// 系统分享面板
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 设置视图

/// 应用信息界面
struct AppInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("双语字幕翻译")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("版本 1.5")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("简单易用的字幕翻译工具，支持SRT格式文件")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text("应用信息")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("功能特点")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• 上传英文SRT字幕文件")
                            Text("• 自动翻译成双语字幕")
                            Text("• 支持预览和下载功能")
                            Text("• 完全免费使用")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                } header: {
                    Text("功能")
                }
                
                Section {
                    Link("隐私政策", destination: URL(string: "https://github.com/ChrisLou-bioinfo/subtitle_tochinese/blob/main/docs/privacy.html")!)
                    Link("技术支持", destination: URL(string: "https://github.com/ChrisLou-bioinfo/subtitle_tochinese")!)
                } header: {
                    Text("相关链接")
                }
                
                Section {
                    HStack {
                        Text("翻译功能")
                        Spacer()
                        Label("内置翻译", systemImage: "text.bubble")
                            .foregroundColor(.blue)
                    }
                    
                    Text("使用内置翻译功能，完全免费使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("应用信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - Deepseek API服务

/// 内置翻译服务
class DeepseekAPI {
    
    /// 简单的内置翻译功能
    func translate(text: String) async throws -> String {
        // 简单的内置翻译逻辑
        let translations: [String: String] = [
            "hello": "你好",
            "world": "世界",
            "thank you": "谢谢",
            "good morning": "早上好",
            "good afternoon": "下午好",
            "good evening": "晚上好",
            "how are you": "你好吗",
            "i love you": "我爱你",
            "please": "请",
            "sorry": "对不起",
            "yes": "是",
            "no": "不",
            "ok": "好的",
            "help": "帮助"
        ]
        
        // 简单的关键词匹配翻译
        let lowercasedText = text.lowercased()
        for (english, chinese) in translations {
            if lowercasedText.contains(english) {
                return chinese
            }
        }
        
        // 如果没有匹配，返回演示文本
        return "[翻译演示: " + text + "]"
    }
}

// MARK: - 错误类型

enum APIError: LocalizedError {
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器响应无效"
        case .invalidData:
            return "数据格式错误"
        }
    }
}

// MARK: - 预览

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
