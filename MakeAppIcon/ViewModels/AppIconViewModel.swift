//
//  AppIconViewModel.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit
import Combine
import Foundation
import UserNotifications

/// 主视图模型
@MainActor
class AppIconViewModel: ObservableObject {
    
    // MARK: - 输入状态
    
    /// 原始图片
    @Published var originalImage: NSImage?
    
    /// 选中的平台
    @Published var selectedPlatforms: Set<Platform> = Set(Platform.allCases)
    
    /// 当前选中的平台标签
    @Published var selectedPlatformTab: Platform = .iOS
    
    // MARK: - 输出状态
    
    /// 生成的图标（按平台分组）
    @Published var generatedIcons: [Platform: [AppIcon]] = [:]
    
    /// 是否正在处理
    @Published var isProcessing = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    /// 是否显示错误提示
    @Published var showError = false
    
    /// 是否显示保存面板
    @Published var showSavePanel = false
    
    /// 图片信息
    @Published var imageInfo: String?
    
    // MARK: - 计算属性
    
    /// 是否有生成的图标
    var hasGeneratedIcons: Bool {
        !generatedIcons.isEmpty
    }
    
    /// 当前选中平台的图标列表
    var currentPlatformIcons: [AppIcon] {
        generatedIcons[selectedPlatformTab] ?? []
    }
    
    // MARK: - 公共方法
    
    /// 从 URL 加载图片
    /// - Parameter url: 图片 URL
    func loadImage(from url: URL) async {
        // 检查文件格式
        guard ImageProcessor.isSupportedFormat(url) else {
            showError(message: "不支持的图片格式，请上传 PNG、JPG、JPEG 或 HEIC 格式的图片")
            return
        }
        
        // 加载图片
        guard let image = ImageProcessor.loadImage(from: url) else {
            showError(message: "无法加载图片")
            return
        }
        
        // 验证图片
        let validation = ImageProcessor.validate(image)
        guard validation.isValid else {
            showError(message: validation.message)
            return
        }
        
        // 设置图片
        self.originalImage = image
        
        // 更新图片信息
        if let size = ImageProcessor.getActualSize(of: image) {
            self.imageInfo = "尺寸: \(Int(size.width))×\(Int(size.height)) ✓"
        }
        
        // 自动生成图标
        await generateAllIcons()
    }
    
    /// 生成所有选中平台的图标
    func generateAllIcons() async {
        guard let image = originalImage else {
            return
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        // 清空之前的图标
        generatedIcons = [:]
        
        // 为每个选中的平台生成图标
        for platform in selectedPlatforms {
            var icons: [AppIcon] = []
            
            for iconSize in platform.iconSizes {
                var icon = AppIcon(originalImage: image, size: iconSize)
                icon.generate()
                icons.append(icon)
            }
            
            generatedIcons[platform] = icons
        }
    }
    
    /// 保存所有图标
    func saveAllIcons() async {
        guard !generatedIcons.isEmpty else {
            showError(message: "没有可保存的图标")
            return
        }
        
        // 显示保存面板
        guard let directory = FileExporter.showSavePanel() else {
            return
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            try await FileExporter.saveAll(generatedIcons, to: directory)
            
            // 显示成功提示
            let totalCount = generatedIcons.values.reduce(0) { $0 + $1.count }
            let platformCount = generatedIcons.keys.count
            let message = "成功保存 \(totalCount) 个图标到 \(platformCount) 个平台"
            
            // 使用系统通知显示成功消息
            showSuccessNotification(message: message)
            
        } catch {
            showError(message: error.localizedDescription)
        }
    }
    
    /// 切换平台选择
    /// - Parameter platform: 平台
    func togglePlatform(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            // 至少保留一个平台
            if selectedPlatforms.count > 1 {
                selectedPlatforms.remove(platform)
                generatedIcons.removeValue(forKey: platform)
            }
        } else {
            selectedPlatforms.insert(platform)
            // 如果有原始图片，立即为新选中的平台生成图标
            if originalImage != nil {
                Task {
                    await generateAllIcons()
                }
            }
        }
    }
    
    /// 清除当前图片
    func clearImage() {
        originalImage = nil
        generatedIcons = [:]
        imageInfo = nil
    }
    
    // MARK: - 私有方法
    
    /// 显示错误消息
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
    
    /// 显示成功通知
    private func showSuccessNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "保存成功"
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
}
