import SwiftUI
import AppKit
import UniformTypeIdentifiers
import QuickLookThumbnailing

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView(viewModel: viewModel)
            .navigationTitle("NanoPress")
            .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 280)
        } detail: {
            // Main Content
            MainContentView(viewModel: viewModel)
        }
        .frame(minWidth: 700, minHeight: 450)
        .preferredColorScheme(viewModel.selectedTheme == .system ? nil : (viewModel.selectedTheme == .dark ? .dark : .light))
    }
}
