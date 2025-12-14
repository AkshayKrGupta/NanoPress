import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var compressor = CompressionLogic()
    @State private var isDraggingOver = false
    @State private var pendingFiles: [URL] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("NanoPress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                if !pendingFiles.isEmpty && !compressor.isProcessing {
                    Button(action: {
                        pendingFiles.removeAll()
                    }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .help("Clear All")
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Main Content Area
            ZStack {
                // Background & Drag Zone
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDraggingOver ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDraggingOver ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                    .animation(.easeInOut, value: isDraggingOver)
                
                VStack(spacing: 20) {
                    if compressor.isProcessing {
                        VStack(spacing: 15) {
                            ProgressView(value: compressor.progress)
                                .progressViewStyle(.linear)
                                .frame(width: 200)
                            Text(compressor.statusMessage)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(compressor.completedCount) / \(pendingFiles.count)")
                                .font(.caption)
                                .monospacedDigit()
                        }
                    } else if pendingFiles.isEmpty {
                        // Empty State
                        VStack(spacing: 15) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("Drop Files Here")
                                .font(.title2)
                                .fontWeight(.medium)
                            Text("JPG, PNG, PDF")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // Pending Files List
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(pendingFiles, id: \.self) { url in
                                    HStack {
                                        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                        VStack(alignment: .leading) {
                                            Text(url.lastPathComponent)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                            Text(formatSize(url))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding(20)
            .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
                handleDrop(providers: providers)
                return true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Footer Controls
            VStack(spacing: 12) {
                 HStack {
                    Text("Quality")
                    Slider(value: $compressor.imageQuality, in: 0.1...1.0)
                    Text("\(Int(compressor.imageQuality * 100))%")
                        .monospacedDigit()
                        .frame(width: 40)
                 }
                 
                 Button(action: selectOutputAndCompress) {
                     HStack {
                         Text("Compress & Save...")
                             .fontWeight(.semibold)
                         Image(systemName: "arrow.right.circle.fill")
                     }
                     .frame(maxWidth: .infinity)
                     .padding(6)
                 }
                 .buttonStyle(.borderedProminent)
                 .disabled(pendingFiles.isEmpty || compressor.isProcessing)
                 .controlSize(.large)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            // Deduplicate
                            if !pendingFiles.contains(url) {
                                pendingFiles.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func selectOutputAndCompress() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Output Folder"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                 compressor.compressFiles(pendingFiles, to: url) {
                     // Completion
                     // Optionally show alert or reveal
                     NSWorkspace.shared.activateFileViewerSelecting([url])
                     // Clear files? Or keep them? Let's keep them and maybe show status.
                     // For now, user can clear manually.
                 }
            }
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
