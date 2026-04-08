//
//  FileExporter.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit
import Foundation

/// 错误类型定义
enum IconError: LocalizedError {
    case invalidImageFormat
    case imageTooSmall(minSize: Int, actualSize: Int)
    case imageNotSquare(width: Int, height: Int)
    case imageConversionFailed
    case fileSaveFailed(Error)
    case directoryCreationFailed(Error)
    case noIconsToSave
    
    var errorDescription: String? {
        switch self {
        case .invalidImageFormat:
            return "不支持的图片格式"
        case .imageTooSmall(let minSize, let actualSize):
            return "图片尺寸过小，最小需要 \(minSize)×\(minSize)，实际为 \(actualSize)×\(actualSize)"
        case .imageNotSquare(let width, let height):
            return "图片必须是正方形，实际尺寸为 \(width)×\(height)"
        case .imageConversionFailed:
            return "图片转换失败"
        case .fileSaveFailed(let error):
            return "保存文件失败: \(error.localizedDescription)"
        case .directoryCreationFailed(let error):
            return "创建目录失败: \(error.localizedDescription)"
        case .noIconsToSave:
            return "没有可保存的图标"
        }
    }
}

/// 文件导出服务
enum FileExporter {
    
    /// 保存单个图标
    /// - Parameters:
    ///   - image: 图片对象
    ///   - url: 目标目录 URL
    ///   - fileName: 文件名
    /// - Throws: 保存失败时抛出错误
    static func save(_ image: NSImage, to url: URL, fileName: String) throws {
        // 转换为 PNG 数据
        guard let tiffData = image.tiffRepresentation else {
            print("Failed to get TIFF representation")
            throw IconError.imageConversionFailed
        }
        
        guard let bitmap = NSBitmapImageRep(data: tiffData) else {
            print("Failed to create bitmap from TIFF data")
            throw IconError.imageConversionFailed
        }
        
        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("Failed to convert to PNG")
            throw IconError.imageConversionFailed
        }
        
        // 构建文件 URL
        let fileURL = url.appendingPathComponent(fileName)
        
        // 写入文件
        do {
            // 如果文件已存在，先删除
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            try pngData.write(to: fileURL, options: [.atomic])
            print("Successfully saved: \(fileName)")
        } catch {
            print("Failed to save \(fileName): \(error)")
            throw IconError.fileSaveFailed(error)
        }
    }
    
    /// 批量保存所有图标
    /// - Parameters:
    ///   - icons: 按平台分组的图标字典
    ///   - directory: 目标目录
    /// - Throws: 保存失败时抛出错误
    static func saveAll(_ icons: [Platform: [AppIcon]], to directory: URL) async throws {
        // 检查是否有图标
        guard !icons.isEmpty else {
            throw IconError.noIconsToSave
        }
        
        // 访问安全作用域资源
        let accessed = directory.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                directory.stopAccessingSecurityScopedResource()
            }
        }
        
        print("Saving to: \(directory.path)")
        print("Access granted: \(accessed)")
        
        // 创建文件夹结构
        let platforms = Array(icons.keys)
        try createDirectoryStructure(at: directory, platforms: platforms)
        
        // 保存所有图标
        var savedCount = 0
        for (platform, platformIcons) in icons {
            let platformURL = directory.appendingPathComponent(platform.rawValue)
            
            for var icon in platformIcons {
                // 确保图标已生成
                if !icon.isGenerated {
                    icon.generate()
                }
                
                guard let generatedImage = icon.generatedImage else {
                    print("Failed to generate icon: \(icon.size.fileName)")
                    continue
                }
                
                try save(generatedImage, to: platformURL, fileName: icon.size.fileName)
                savedCount += 1
            }
        }
        
        print("Successfully saved \(savedCount) icons")
    }
    
    /// 创建文件夹结构
    /// - Parameters:
    ///   - url: 基础目录 URL
    ///   - platforms: 平台列表
    /// - Throws: 创建失败时抛出错误
    static func createDirectoryStructure(at url: URL, platforms: [Platform]) throws {
        let fileManager = FileManager.default
        
        // 创建主目录
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("Created directory: \(url.path)")
            } catch {
                print("Failed to create main directory: \(error)")
                throw IconError.directoryCreationFailed(error)
            }
        }
        
        // 为每个平台创建子目录
        for platform in platforms {
            let platformURL = url.appendingPathComponent(platform.rawValue)
            if !fileManager.fileExists(atPath: platformURL.path) {
                do {
                    try fileManager.createDirectory(at: platformURL, withIntermediateDirectories: true, attributes: nil)
                    print("Created platform directory: \(platform.rawValue)")
                } catch {
                    print("Failed to create platform directory \(platform.rawValue): \(error)")
                    throw IconError.directoryCreationFailed(error)
                }
            }
        }
    }
    
    /// 显示保存面板并获取用户选择的目录
    /// - Returns: 用户选择的目录 URL，取消返回 nil
    @MainActor
    static func showSavePanel() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.message = "选择保存 App Icon 的位置"
        panel.prompt = "选择"
        panel.title = "保存 App Icon"
        
        let response = panel.runModal()
        
        if response == .OK, let url = panel.url {
            // 关键：使用 bookmark 数据来保持访问权限
            do {
                let bookmarkData = try url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                
                // 从 bookmark 恢复 URL
                var isStale = false
                let secureURL = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                
                return secureURL
            } catch {
                print("Failed to create bookmark: \(error)")
                // 如果 bookmark 失败，仍然返回原始 URL
                return url
            }
        }
        
        return nil
    }
}
