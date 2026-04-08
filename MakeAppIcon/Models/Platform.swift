//
//  Platform.swift
//  MakeAppIcon
//
//  Created on 2026-04-08.
//

import Foundation

/// Apple 平台类型
enum Platform: String, CaseIterable, Identifiable {
    case iOS = "iOS"
    case macOS = "macOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"
    
    var id: String { rawValue }
    
    /// 该平台所需的所有图标尺寸
    var iconSizes: [IconSize] {
        switch self {
        case .iOS:
            return Self.iOSIconSizes
        case .macOS:
            return Self.macOSIconSizes
        case .watchOS:
            return Self.watchOSIconSizes
        case .tvOS:
            return Self.tvOSIconSizes
        }
    }
    
    // MARK: - iOS Icon Sizes
    
    private static let iOSIconSizes: [IconSize] = [
        // iPhone Notification
        IconSize(width: 20, height: 20, platform: .iOS, description: "iPhone Notification @1x"),
        IconSize(width: 40, height: 40, platform: .iOS, description: "iPhone Notification @2x"),
        IconSize(width: 60, height: 60, platform: .iOS, description: "iPhone Notification @3x"),
        
        // iPhone Settings
        IconSize(width: 29, height: 29, platform: .iOS, description: "iPhone Settings @1x"),
        IconSize(width: 58, height: 58, platform: .iOS, description: "iPhone Settings @2x"),
        IconSize(width: 87, height: 87, platform: .iOS, description: "iPhone Settings @3x"),
        
        // iPhone Spotlight
        IconSize(width: 40, height: 40, platform: .iOS, description: "iPhone Spotlight @1x"),
        IconSize(width: 80, height: 80, platform: .iOS, description: "iPhone Spotlight @2x"),
        IconSize(width: 120, height: 120, platform: .iOS, description: "iPhone Spotlight @3x"),
        
        // iPhone App
        IconSize(width: 60, height: 60, platform: .iOS, description: "iPhone App @1x"),
        IconSize(width: 120, height: 120, platform: .iOS, description: "iPhone App @2x"),
        IconSize(width: 180, height: 180, platform: .iOS, description: "iPhone App @3x"),
        
        // iPad Notification
        // 20x20 和 40x40 已在 iPhone Notification 中定义
        
        // iPad Settings
        // 29x29 和 58x58 已在 iPhone Settings 中定义
        
        // iPad Spotlight
        // 40x40 和 80x80 已在 iPhone Spotlight 中定义
        
        // iPad App
        IconSize(width: 76, height: 76, platform: .iOS, description: "iPad App @1x"),
        IconSize(width: 152, height: 152, platform: .iOS, description: "iPad App @2x"),
        
        // iPad Pro 12.9
        IconSize(width: 167, height: 167, platform: .iOS, description: "iPad Pro 12.9 App @2x"),
        
        // App Store
        IconSize(width: 1024, height: 1024, platform: .iOS, description: "App Store")
    ]
    
    // MARK: - macOS Icon Sizes
    
    private static let macOSIconSizes: [IconSize] = [
        IconSize(width: 16, height: 16, platform: .macOS, description: "macOS 16px @1x"),
        IconSize(width: 32, height: 32, platform: .macOS, description: "macOS 16px @2x / 32px @1x"),
        IconSize(width: 64, height: 64, platform: .macOS, description: "macOS 32px @2x"),
        IconSize(width: 128, height: 128, platform: .macOS, description: "macOS 128px @1x"),
        IconSize(width: 256, height: 256, platform: .macOS, description: "macOS 128px @2x / 256px @1x"),
        IconSize(width: 512, height: 512, platform: .macOS, description: "macOS 256px @2x / 512px @1x"),
        IconSize(width: 1024, height: 1024, platform: .macOS, description: "macOS 512px @2x")
    ]
    
    // MARK: - watchOS Icon Sizes
    
    private static let watchOSIconSizes: [IconSize] = [
        // Home Screen Icons
        IconSize(width: 80, height: 80, platform: .watchOS, description: "watchOS 38mm Home Screen"),
        IconSize(width: 88, height: 88, platform: .watchOS, description: "watchOS 40mm Home Screen"),
        IconSize(width: 92, height: 92, platform: .watchOS, description: "watchOS 41mm Home Screen"),
        IconSize(width: 100, height: 100, platform: .watchOS, description: "watchOS 44mm Home Screen"),
        IconSize(width: 102, height: 102, platform: .watchOS, description: "watchOS 45mm Home Screen"),
        IconSize(width: 108, height: 108, platform: .watchOS, description: "watchOS 49mm Home Screen"),
        
        // Notification Center Icons
        IconSize(width: 48, height: 48, platform: .watchOS, description: "watchOS 38mm Notification"),
        IconSize(width: 55, height: 55, platform: .watchOS, description: "watchOS 40mm/42mm Notification"),
        IconSize(width: 58, height: 58, platform: .watchOS, description: "watchOS 41mm/44mm Notification"),
        IconSize(width: 66, height: 66, platform: .watchOS, description: "watchOS 45mm/49mm Notification"),
        
        // Short-Look Icons
        IconSize(width: 172, height: 172, platform: .watchOS, description: "watchOS 38mm Short-Look"),
        IconSize(width: 196, height: 196, platform: .watchOS, description: "watchOS 40mm/41mm/42mm Short-Look"),
        IconSize(width: 216, height: 216, platform: .watchOS, description: "watchOS 44mm Short-Look"),
        IconSize(width: 234, height: 234, platform: .watchOS, description: "watchOS 45mm Short-Look"),
        IconSize(width: 258, height: 258, platform: .watchOS, description: "watchOS 49mm Short-Look"),
        
        // iPhone Companion App Icons
        IconSize(width: 87, height: 87, platform: .watchOS, description: "watchOS Companion Settings @3x"),
        
        // App Store
        IconSize(width: 1024, height: 1024, platform: .watchOS, description: "App Store")
    ]
    
    // MARK: - tvOS Icon Sizes
    
    private static let tvOSIconSizes: [IconSize] = [
        // Home Screen
        IconSize(width: 400, height: 240, platform: .tvOS, description: "tvOS Home Screen @1x"),
        IconSize(width: 800, height: 480, platform: .tvOS, description: "tvOS Home Screen @2x"),
        
        // App Store
        IconSize(width: 1280, height: 768, platform: .tvOS, description: "tvOS App Store"),
        
        // Top Shelf
        IconSize(width: 1920, height: 720, platform: .tvOS, description: "tvOS Top Shelf Static"),
        IconSize(width: 2320, height: 720, platform: .tvOS, description: "tvOS Top Shelf Dynamic @1x"),
        IconSize(width: 4640, height: 1440, platform: .tvOS, description: "tvOS Top Shelf Dynamic @2x")
    ]
}
