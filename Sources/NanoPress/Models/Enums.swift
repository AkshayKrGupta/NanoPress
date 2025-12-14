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


