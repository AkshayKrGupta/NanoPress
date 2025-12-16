import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var compressor = CompressionManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        compressor.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    @Published var pendingFiles: [URL] = []
    @Published var selectedSidebarItem: SidebarItem? = .general
    @Published var selectedTheme: AppTheme = .system

    
    // UI State for Drag
    @Published var isDraggingOver = false
    
    // Notification State
    @Published var showNotification = false

    @Published var notificationMessage = ""
    @Published var isErrorNotification = false
    
    // Logic Helpers
    func selectFiles() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Files to Compress"
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [.image, .pdf]
        
        openPanel.begin { result in
            if result == .OK {
                DispatchQueue.main.async {
                     withAnimation(.spring()) {
                         for url in openPanel.urls {
                             self.addFile(url)
                         }
                     }
                }
            }
        }
    }
    
    func addFile(_ url: URL) {
        // 1. Validation
        let allowedExtensions = ["jpg", "jpeg", "png", "heic", "tif", "tiff", "pdf"]
        let ext = url.pathExtension.lowercased()
        guard allowedExtensions.contains(ext) else {
            showError(message: "Unsupported file type: \(ext)")
            return
        }
        
        // 2. Deduplication
        guard !pendingFiles.contains(url) else {
            showError(message: "File already added: \(url.lastPathComponent)")
            return
        }
        
        // 3. Add
        pendingFiles.append(url)
    }

    func showError(message: String) {
        notificationMessage = message
        isErrorNotification = true
        withAnimation {
            showNotification = true
        }
        // Auto dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showNotification = false
                self.isErrorNotification = false
            }
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            withAnimation(.spring()) {
                                self.addFile(url)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startCompression() {
        guard !compressor.isProcessing else { return }
        withAnimation {
             compressor.compressFiles(pendingFiles, strategy: .sameAsOriginal)
        }
    }
    
    func themeIcon(for theme: AppTheme) -> String {
        switch theme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gearshape.fill"
        }
    }
}
