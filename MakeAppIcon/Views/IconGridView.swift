//
//  IconGridView.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit
import SwiftUI

/// 图标网格视图
struct IconGridView: View {
    @ObservedObject var viewModel: AppIconViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 平台选择标签
            PlatformTabBar(viewModel: viewModel)
            
            Divider()
            
            // 图标网格
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 120, maximum: 150), spacing: 16)
                    ],
                    spacing: 20
                ) {
                    ForEach(viewModel.currentPlatformIcons) { icon in
                        IconItemView(icon: icon)
                    }
                }
                .padding()
            }
            .background(Color(NSColor.textBackgroundColor))
        }
    }
}

/// 平台标签栏
struct PlatformTabBar: View {
    @ObservedObject var viewModel: AppIconViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(viewModel.selectedPlatforms), id: \.self) { platform in
                Button(action: {
                    viewModel.selectedPlatformTab = platform
                }) {
                    HStack(spacing: 8) {
                        Text(platform.rawValue)
                            .font(.subheadline)
                        
                        // 显示图标数量
                        if let count = viewModel.generatedIcons[platform]?.count {
                            Text("\(count)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedPlatformTab == platform ? 
                                              Color.white.opacity(0.3) : 
                                                Color.secondary.opacity(0.2))
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.selectedPlatformTab == platform ?
                        Color.accentColor :
                        Color.clear
                    )
                    .foregroundColor(
                        viewModel.selectedPlatformTab == platform ?
                        .white :
                        .primary
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

/// 单个图标项视图
struct IconItemView: View {
    let icon: AppIcon
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 图标预览
            ZStack {
                // 棋盘格背景（显示透明度）
                CheckerboardBackground()
                    .cornerRadius(8)
                
                // 图标
                let image = icon.generatedImage ?? icon.originalImage
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
            }
            .frame(width: 80, height: 80)
            .shadow(radius: isHovered ? 8 : 2)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            
            // 文件名
            VStack(spacing: 2) {
                Text(icon.size.sizeDescription)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(icon.size.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(width: 100)
    }
}

/// 棋盘格背景视图（用于显示透明度）
struct CheckerboardBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let size = 8.0
            let rows = Int(ceil(geometry.size.height / size))
            let cols = Int(ceil(geometry.size.width / size))
            
            ZStack {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        Rectangle()
                            .fill(
                                (row + col) % 2 == 0 ?
                                Color(NSColor.separatorColor) :
                                    Color(NSColor.controlBackgroundColor)
                            )
                            .frame(width: size, height: size)
                            .position(
                                x: CGFloat(col) * size + size / 2,
                                y: CGFloat(row) * size + size / 2
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = AppIconViewModel()
    // 添加一些测试数据
    let testImage = NSImage(systemSymbolName: "app.fill", accessibilityDescription: nil)!
    viewModel.originalImage = testImage
    viewModel.generatedIcons = [
        .iOS: [
            AppIcon(originalImage: testImage, size: IconSize(width: 1024, height: 1024, platform: .iOS, description: "Test"))
        ]
    ]
    
    return IconGridView(viewModel: viewModel)
        .frame(width: 600, height: 500)
}
