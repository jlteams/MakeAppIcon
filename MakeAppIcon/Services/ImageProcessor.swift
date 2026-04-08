//
//  ImageProcessor.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit
import CoreGraphics

/// 图片处理服务
enum ImageProcessor {
    
    /// 验证图片是否符合要求
    /// - Parameter image: 待验证的图片
    /// - Returns: 验证结果（是否有效，错误消息）
    static func validate(_ image: NSImage) -> (isValid: Bool, message: String) {
        guard let size = getActualSize(of: image) else {
            return (false, "无法读取图片尺寸")
        }
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        // 检查是否为正方形
        guard size.width == size.height else {
            return (false, "图片必须是正方形（当前: \(width)×\(height)）")
        }
        
        // 检查最小尺寸
        guard size.width >= 1024 else {
            return (false, "图片尺寸至少需要 1024×1024（当前: \(width)×\(height)）")
        }
        
        return (true, "验证通过")
    }
    
    /// 获取图片的实际尺寸（考虑 DPI）
    /// - Parameter image: 图片对象
    /// - Returns: 实际尺寸（像素）
    static func getActualSize(of image: NSImage) -> CGSize? {
        // 获取 CGImage 以获取实际像素尺寸
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        return CGSize(width: width, height: height)
    }
    
    /// 缩放图片到指定尺寸
    /// - Parameters:
    ///   - image: 原始图片
    ///   - targetSize: 目标尺寸
    /// - Returns: 缩放后的图片
    static func resize(_ image: NSImage, to targetSize: CGSize) -> NSImage {
        // 如果尺寸相同，直接返回原图
        if let currentSize = getActualSize(of: image),
           currentSize.width == targetSize.width && currentSize.height == targetSize.height {
            return image
        }
        
        // 获取 CGImage
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Failed to get CGImage from NSImage")
            return image
        }
        
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        
        // 创建颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 创建位图上下文
        // 使用 premultipliedLast 保持透明度
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            print("Failed to create CGContext")
            return image
        }
        
        // 设置高质量插值
        context.interpolationQuality = .high
        
        // 绘制图片
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 创建新图片
        guard let newCGImage = context.makeImage() else {
            print("Failed to create CGImage from context")
            return image
        }
        
        let newImage = NSImage(cgImage: newCGImage, size: targetSize)
        return newImage
    }
    
    /// 从 URL 加载图片
    /// - Parameter url: 图片 URL
    /// - Returns: 加载的图片，失败返回 nil
    static func loadImage(from url: URL) -> NSImage? {
        // 检查是否为文件 URL
        guard url.isFileURL else {
            print("URL is not a file URL: \(url)")
            return nil
        }
        
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("File does not exist: \(url.path)")
            return nil
        }
        
        // 开始访问安全作用域资源（用于 App Sandbox）
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // 创建 NSImage
        let image = NSImage(contentsOf: url)
        
        if image == nil {
            print("Failed to load image from: \(url.path)")
        }
        
        return image
    }
    
    /// 支持的图片格式
    static let supportedExtensions = ["png", "jpg", "jpeg", "heic"]
    
    /// 检查文件扩展名是否支持
    /// - Parameter url: 文件 URL
    /// - Returns: 是否支持
    static func isSupportedFormat(_ url: URL) -> Bool {
        guard let extensionString = url.pathExtension.lowercased() as String? else {
            return false
        }
        return supportedExtensions.contains(extensionString)
    }
}
