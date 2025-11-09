//
//  ContentView.swift
//  YouTubeSubtitleApp
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
                    if !selectedFileName.isEmpty {
                        translateButtonView
                    }
                    
                    // 进度显示
                    if isProcessing {
                        progressView
                    }
                    
                    // 状态信息
                    statusView
                    
                    // 操作按钮组
                    if !subtitles.isEmpty {
                        actionButtonsView
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("SRT字幕翻译")
            .navigationBarTitleDisplayMode(.inline)
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
        Button(action: startProcessing) {
            HStack {
                Image(systemName: isProcessing ? "arrow.triangle.2.circlepath" : "wand.and.stars")
                Text(isProcessing ? "翻译中..." : "开始翻译")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isProcessing ? Color.orange : Color.blue)
            .cornerRadius(10)
        }
        .disabled(isProcessing)
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
    
    // MARK: - 计算属性
    
    private var statusIcon: String {
        if isProcessing {
            return "arrow.triangle.2.circlepath"
        } else if !subtitles.isEmpty {
            return "checkmark.circle.fill"
        } else {
            return "info.circle"
        }
    }
    
    private var statusColor: Color {
        if isProcessing {
            return .blue
        } else if !subtitles.isEmpty {
            return .green
        } else {
            return .gray
        }
    }
    
    // MARK: - 核心功能
    
    /// 开始处理视频
    private func startProcessing() {
        Task {
            await processVideo()
        }
    }
    
    /// 处理视频的主要流程
    private func processVideo() async {
        isProcessing = true
        progress = 0
        subtitles = []
        
        do {
            // 步骤1: 验证URL
            updateStatus("验证YouTube链接...")
            progress = 10
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            
            // 步骤2: 下载字幕
            updateStatus("下载英文字幕...")
            progress = 30
            let downloadedSubtitles = try await downloadSubtitles(url: youtubeURL)
            
            // 步骤3: 翻译字幕
            updateStatus("翻译字幕中...")
            progress = 50
            let translatedSubtitles = try await translateSubtitles(downloadedSubtitles)
            
            // 步骤4: 完成
            progress = 100
            subtitles = translatedSubtitles
            updateStatus("处理完成！共 \(subtitles.count) 条字幕")
            
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            updateStatus("处理失败")
        }
        
        isProcessing = false
    }
    
    /// 下载字幕（真实实现）
    private func downloadSubtitles(url: String) async throws -> [SubtitleBlock] {
        // 提取YouTube视频ID
        let videoId = extractYouTubeVideoId(from: url)
        guard let videoId = videoId else {
            throw DownloadError.invalidURL
        }
        
        // 获取视频信息
        let videoInfo = try await getYouTubeVideoInfo(videoId: videoId)
        
        // 下载字幕文件
        let subtitleContent = try await downloadYouTubeSubtitles(videoId: videoId)
        
        // 解析SRT字幕
        let blocks = parseSRTContent(subtitleContent)
        
        return blocks
    }
    
    /// 翻译字幕
    private func translateSubtitles(_ subtitles: [SubtitleBlock]) async throws -> [SubtitleBlock] {
        var translatedSubtitles = subtitles
        let api = DeepseekAPI()
        
        for (index, subtitle) in subtitles.enumerated() {
            let translation = try await api.translate(text: subtitle.englishText)
            translatedSubtitles[index].chineseText = translation
            
            // 更新进度
            let currentProgress = 50 + (Double(index + 1) / Double(subtitles.count) * 50)
            progress = currentProgress
        }
        
        return translatedSubtitles
    }
    
    /// 更新状态消息
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            statusMessage = message
        }
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
                    Text(subtitle.timeline)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(subtitle.englishText)
                        .font(.body)
                    
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

// MARK: - Deepseek API服务

/// Deepseek翻译API服务
class DeepseekAPI {
    private let apiKey = "sk-8fc6d65b137148bbb0470a815f969937" // 从配置文件读取
    private let baseURL = "https://api.deepseek.com"
    
    /// 翻译文本
    func translate(text: String) async throws -> String {
        let url = URL(string: "\(baseURL)/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": "你是一个专业的翻译助手，请将英文准确翻译成中文，保持简洁明了。"],
                ["role": "user", "content": "请翻译以下英文文本为中文：\(text)"]
            ],
            "temperature": 0.3,
            "max_tokens": 1000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidData
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
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
