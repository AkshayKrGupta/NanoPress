//
//  ContentViewModel.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

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
    @Published var selectedFiles: Set<URL> = []
    @Published var lastSelectedFile: URL? = nil
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
    
    // MARK: - Keyboard Actions
    
    func handleKeyCommand(_ key: String, modifiers: NSEvent.ModifierFlags) {
        if modifiers.contains(.command) {
            switch key.lowercased() {
            case "o":
                selectFiles()
            case "r":
                if !compressor.isProcessing && !pendingFiles.isEmpty {
                    startCompression()
                }
            default:
                break
            }
        } else if key == String(UnicodeScalar(NSDeleteCharacter)!) || key == String(UnicodeScalar(NSBackspaceCharacter)!) {
            if modifiers.contains(.command) {
                removeSelectedFiles()
            }
        } else if key == String(UnicodeScalar(27)!) { // Escape
            clearCompleted()
        }
    }
    
    func toggleFileSelection(_ url: URL, modifiers: NSEvent.ModifierFlags) {
        if modifiers.contains(.command) {
            // Command+Click: Toggle individual selection
            if selectedFiles.contains(url) {
                selectedFiles.remove(url)
            } else {
                selectedFiles.insert(url)
                lastSelectedFile = url
            }
        } else if modifiers.contains(.shift), let lastSelected = lastSelectedFile,
                  let startIndex = pendingFiles.firstIndex(of: lastSelected),
                  let endIndex = pendingFiles.firstIndex(of: url) {
            // Shift+Click: Select range
            let range = min(startIndex, endIndex)...max(startIndex, endIndex)
            for i in range {
                selectedFiles.insert(pendingFiles[i])
            }
            lastSelectedFile = url
        } else {
            // Regular click: Select only this file
            selectedFiles = [url]
            lastSelectedFile = url
        }
    }
    
    func removeSelectedFiles() {
        guard !selectedFiles.isEmpty else { return }
        withAnimation {
            pendingFiles.removeAll { selectedFiles.contains($0) }
            selectedFiles.removeAll()
        }
    }
    
    func clearCompleted() {
        withAnimation {
            if !compressor.completedResults.isEmpty {
                compressor.completedResults.removeAll()
                pendingFiles.removeAll()
                selectedFiles.removeAll()
            }
        }
    }
}
