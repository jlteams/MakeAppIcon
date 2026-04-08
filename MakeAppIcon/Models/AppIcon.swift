//
//  AppIcon.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit

/// 生成的应用图标模型
struct AppIcon: Identifiable {
    let id = UUID()
    let originalImage: NSImage
    let size: IconSize
    private(set) var generatedImage: NSImage?
    
    /// 生成指定尺寸的图标
    mutating func generate() {
        generatedImage = ImageProcessor.resize(originalImage, to: size.size)
    }
    
    /// 判断是否已生成
    var isGenerated: Bool {
        generatedImage != nil
    }
}
