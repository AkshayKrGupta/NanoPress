//
//  Enums.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import Foundation

// Sidebar Item Model
enum SidebarItem: String, CaseIterable, Identifiable {
    case general = "General"
    case advanced = "Advanced"
    
    var id: String { rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
}

enum PDFCompressionMode: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case aggressive = "Aggressive"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .standard:
            return "Balanced quality and size"
        case .aggressive:
            return "Maximum compression, lower quality"
        }
    }
}


