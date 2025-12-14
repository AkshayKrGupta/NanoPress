import SwiftUI
import AppKit
import UniformTypeIdentifiers
import QuickLookThumbnailing

// Custom rounded font helper
extension Font {
    static func proRounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        return Font.system(style, design: .rounded).weight(weight)
    }
}

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

enum OutputPreference: String, CaseIterable, Identifiable {
    case nextToOriginal = "Save Next to Original"
    case askEveryTime = "Ask Every Time"
    
    var id: String { rawValue }
}

struct ContentView: View {
    @StateObject private var compressor = CompressionManager()
    @State private var pendingFiles: [URL] = []
    @State private var selectedSidebarItem: SidebarItem? = .general
    @State private var selectedTheme: AppTheme = .system
    @State private var outputPreference: OutputPreference = .nextToOriginal
    
    // UI State for Drag
    @State private var isDraggingOver = false
    
    var body: some View {
        NavigationView {
            // MARK: - Sidebar
            List {
                Section(header: Text("Settings")) {
                    VStack(alignment: .leading, spacing: 15) {
                        // Quality Slider
                        VStack(alignment: .leading) {
                            Label("Image Quality", systemImage: "photo.on.rectangle")
                                .font(.proRounded(.subheadline, weight: .medium))
                            
                            HStack {
                                Slider(value: $compressor.imageQuality, in: 0.1...1.0, step: 0.05)
                                    .tint(.blue)
                                Text("\(Int(compressor.imageQuality * 100))%")
                                    .font(.proRounded(.caption))
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                                    .frame(width: 35)
                            }
                        }
                        
                        Divider()
                        
                        // Output Preference
                        VStack(alignment: .leading) {
                            Label("Output", systemImage: "folder")
                                .font(.proRounded(.subheadline, weight: .medium))
                            Picker("", selection: $outputPreference) {
                                ForEach(OutputPreference.allCases) { pref in
                                    Text(pref.rawValue).tag(pref)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("NanoPress")
            .frame(minWidth: 200)
            
            // MARK: - Main Content
            ZStack {
                Color(NSColor.controlBackgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                         if let imagePath = Bundle.module.path(forResource: "AppIcon", ofType: "png"),
                            let nsImage = NSImage(contentsOfFile: imagePath) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                         }
                         Text("NanoPress")
                             .font(.headline)
                         Spacer()
                    }
                    .padding()
                    .background(Material.bar)
                    
                    if !compressor.completedResults.isEmpty && !compressor.isProcessing {
                        // Completed View
                        VStack {
                            HStack {
                                Text("Compression Complete")
                                    .font(.proRounded(.title2, weight: .bold))
                                Spacer()
                                Button("Done") {
                                    compressor.completedResults.removeAll()
                                    pendingFiles.removeAll()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                            
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(compressor.completedResults, id: \.self) { result in
                                        CompletedFileRowView(result: result)
                                    }
                                }
                                .padding()
                            }
                        }
                    } else if pendingFiles.isEmpty {
                        // Empty State
                        EmptyStateView(isDraggingOver: isDraggingOver, onBrowse: selectFiles)
                            .frame(maxHeight: .infinity)
                    } else {
                        // File List
                        VStack(spacing: 0) {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(pendingFiles, id: \.self) { url in
                                        FileRowView(url: url) {
                                            if let index = pendingFiles.firstIndex(of: url) {
                                                pendingFiles.remove(at: index)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            
                            // Main Compress Button (Only if not processing)
                            if !compressor.isProcessing {
                                Divider()
                                HStack {
                                    Button(action: startCompression) {
                                        HStack {
                                            Image(systemName: "arrow.right.circle.fill")
                                            Text("Compress Files")
                                                .font(.proRounded(.headline))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.large)
                                    .padding()
                                }
                                .background(Material.bar)
                            }
                        }
                    }
                    
                    // Permanent Status Bar
                    StatusBarView(
                        progress: compressor.progress,
                        statusMessage: compressor.statusMessage,
                        completedCount: compressor.completedCount,
                        totalCount: pendingFiles.count
                    )
                }
            }
            .toolbar {
                 ToolbarItemGroup(placement: .primaryAction) {
                     if !compressor.isProcessing {
                         Button(action: selectFiles) {
                             Image(systemName: "plus")
                         }
                         .help("Add Files")
                     }
                 }
            }
            .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
                handleDrop(providers: providers)
                return true
            }
        }
        .frame(minWidth: 700, minHeight: 450)
        .preferredColorScheme(selectedTheme == .system ? nil : (selectedTheme == .dark ? .dark : .light))
    }
    
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
                     for url in openPanel.urls {
                         if !pendingFiles.contains(url) {
                             pendingFiles.append(url)
                         }
                     }
                }
            }
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            if !pendingFiles.contains(url) {
                                pendingFiles.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startCompression() {
        if outputPreference == .nextToOriginal {
             compressor.compressFiles(pendingFiles, strategy: .sameAsOriginal)
        } else {
            let openPanel = NSOpenPanel()
            openPanel.title = "Select Output Folder"
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.allowsMultipleSelection = false
            
            openPanel.begin { result in
                if result == .OK, let url = openPanel.url {
                     compressor.compressFiles(pendingFiles, strategy: .specific(url))
                }
            }
        }
    }
}

// MARK: - Subviews

struct EmptyStateView: View {
    var isDraggingOver: Bool
    var onBrowse: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(isDraggingOver ? 0.2 : 0.05))
                    .frame(width: 140, height: 140)
                    .animation(.spring(), value: isDraggingOver)
                
                // App Logo or Symbol
                if let imagePath = Bundle.module.path(forResource: "AppIcon", ofType: "png"),
                   let nsImage = NSImage(contentsOfFile: imagePath) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .shadow(radius: 10)
                        .onTapGesture {
                             onBrowse()
                        }
                } else {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(isDraggingOver ? Color.accentColor : .secondary)
                }
            }
            
            VStack(spacing: 12) {
                Text("Drop Files Here")
                    .font(.proRounded(.title2, weight: .semibold))
                
                Text("- or -")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                
                Button("Browse Files") {
                     onBrowse()
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                Text("Support for JPG, PNG, and PDF")
                    .font(.proRounded(.footnote))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
        }
    }
}

struct FileRowView: View {
    let url: URL
    let onRemove: () -> Void
    @State private var thumbnail: NSImage? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            ThumbnailView(url: url)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.proRounded(.body, weight: .medium))
                    .lineLimit(1)
                
                Text(formatSize(url))
                    .font(.proRounded(.caption))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .onDrag {
            return NSItemProvider(contentsOf: url) ?? NSItemProvider()
        }
    }
    
    func formatSize(_ url: URL) -> String {
        guard let size = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 else { return "?" }
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: size)
    }
}

struct CompletedFileRowView: View {
    let result: CompressionResult
    
    var body: some View {
        HStack(spacing: 15) {
            ThumbnailView(url: result.destinationURL)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.originalURL.lastPathComponent)
                    .font(.proRounded(.body, weight: .medium))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(formatBytes(result.originalSize))
                        .font(.proRounded(.caption))
                        .strikethrough(true)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        
                    Text(formatBytes(result.newSize))
                        .font(.proRounded(.caption, weight: .semibold))
                        .foregroundStyle(.primary)
                
                    if result.originalSize > 0 {
                        let saving = Double(result.originalSize - result.newSize) / Double(result.originalSize) * 100
                        Text("(-\(Int(saving))%)")
                            .font(.caption)
                            .foregroundStyle(saving > 0 ? .green : .orange)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .onDrag {
            return NSItemProvider(contentsOf: result.destinationURL) ?? NSItemProvider()
        }
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: bytes)
    }
}

struct ThumbnailView: View {
    let url: URL
    @State private var thumbnail: NSImage?
    
    var body: some View {
        Group {
            if let thumb = thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: 40, height: 40)
        .cornerRadius(4)
        .onAppear {
             generateThumbnail()
        }
    }
    
    func generateThumbnail() {
        let size = CGSize(width: 80, height: 80)
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .thumbnail)
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
            if let thumbnail = thumbnail {
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail.nsImage
                }
            }
        }
    }
}
