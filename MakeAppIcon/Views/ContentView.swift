//
//  ContentView.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import AppKit
import SwiftUI

/// 主视图
struct ContentView: View {
    @StateObject private var viewModel = AppIconViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            ToolbarView(viewModel: viewModel)
                .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // 主内容区
            HSplitView {
                // 左侧：上传区域
                DropAreaView(viewModel: viewModel)
                    .frame(minWidth: 300, idealWidth: 350, maxWidth: 400)
                
                // 右侧：预览区域
                if viewModel.hasGeneratedIcons {
                    IconGridView(viewModel: viewModel)
                        .frame(minWidth: 500)
                } else {
                    EmptyStateView()
                        .frame(minWidth: 500)
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .alert("错误", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {
                viewModel.showError = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
    }
}

/// 工具栏视图
struct ToolbarView: View {
    @ObservedObject var viewModel: AppIconViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // 应用名称
            Text("MakeAppIcon")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 平台选择
            HStack(spacing: 8) {
                ForEach(Platform.allCases) { platform in
                    PlatformToggleButton(
                        platform: platform,
                        isSelected: viewModel.selectedPlatforms.contains(platform),
                        action: { viewModel.togglePlatform(platform) }
                    )
                }
            }
            
            Divider()
                .frame(height: 20)
            
            // 保存按钮
            Button(action: {
                Task {
                    await viewModel.saveAllIcons()
                }
            }) {
                Label("保存全部", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.hasGeneratedIcons || viewModel.isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

/// 平台选择按钮
struct PlatformToggleButton: View {
    let platform: Platform
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(platform.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.2)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

/// 空状态视图
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("上传图片开始生成")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("支持 PNG、JPG、JPEG、HEIC 格式\n尺寸至少 1024×1024")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }
}

#Preview {
    ContentView()
}
