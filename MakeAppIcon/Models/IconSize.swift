//
//  IconSize.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import CoreGraphics
import Foundation

/// 图标尺寸模型
struct IconSize: Identifiable, Equatable {
    let id = UUID()
    let width: Int
    let height: Int
    let platform: Platform
    let description: String
    
    /// 生成文件名
    /// - Returns: 符合规范的文件名，如 "AppIcon-1024.png" 或 "AppIcon-400x240.png"
    var fileName: String {
        if width == height {
            return "AppIcon-\(width).png"
        } else {
            return "AppIcon-\(width)x\(height).png"
        }
    }
    
    /// 获取实际尺寸（像素）
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    /// 尺寸描述文本
    var sizeDescription: String {
        if width == height {
            return "\(width)×\(height)"
        } else {
            return "\(width)×\(height)"
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: IconSize, rhs: IconSize) -> Bool {
        lhs.width == rhs.width && 
        lhs.height == rhs.height && 
        lhs.platform == rhs.platform
    }
}
