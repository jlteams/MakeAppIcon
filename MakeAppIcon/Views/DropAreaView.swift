//
//  DropAreaView.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// 拖拽上传区域视图
struct DropAreaView: View {
    @ObservedObject var viewModel: AppIconViewModel
    @State private var isTargeted = false
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 拖拽区域
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [8, 4]
                        )
                    )
                    .foregroundColor(isTargeted ? .accentColor : .secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
                    )
                    .frame(width: 260, height: 260)
                
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(isTargeted ? .accentColor : .secondary)
                    
                    Text("拖拽图片到此处")
                        .font(.headline)
                        .foregroundColor(isTargeted ? .accentColor : .primary)
                    
                    Text("或点击选择文件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("支持 PNG、JPG、JPEG、HEIC")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                openFilePicker()
            }
            .onDrop(of: [.fileURL, .image], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
            
            // 图片信息
            if let image = viewModel.originalImage {
                VStack(spacing: 12) {
                    // 图片预览
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    
                    // 图片信息
                    if let info = viewModel.imageInfo {
                        Text(info)
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    // 清除按钮
                    Button(action: {
                        viewModel.clearImage()
                    }) {
                        Label("清除", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            }
            
            // 处理状态
            if viewModel.isProcessing {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("正在生成...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - 私有方法
    
    /// 处理拖拽
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else {
            return false
        }
        
        // 优先处理文件 URL
        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    Task { @MainActor in
                        await viewModel.loadImage(from: url)
                    }
                } else if let error = error {
                    print("Failed to load URL: \(error)")
                }
            }
            return true
        }
        
        // 处理图片数据
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let data = data,
                   let image = NSImage(data: data) {
                    Task { @MainActor in
                        viewModel.originalImage = image
                        if let size = ImageProcessor.getActualSize(of: image) {
                            viewModel.imageInfo = "尺寸: \(Int(size.width))×\(Int(size.height))"
                        }
                        await viewModel.generateAllIcons()
                    }
                } else if let error = error {
                    print("Failed to load image: \(error)")
                }
            }
            return true
        }
        
        return false
    }
    
    /// 打开文件选择器
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        panel.message = "选择图片文件"
        
        if panel.runModal() == .OK, let url = panel.url {
            Task {
                await viewModel.loadImage(from: url)
            }
        }
    }
}

#Preview {
    DropAreaView(viewModel: AppIconViewModel())
        .frame(width: 400, height: 600)
}
