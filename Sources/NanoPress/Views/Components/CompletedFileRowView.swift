import SwiftUI
import AppKit

struct CompletedFileRowView: View {
    let result: CompressionResult
    
    var body: some View {
        HStack(spacing: 15) {
            ThumbnailView(url: result.originalURL) 
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.originalURL.lastPathComponent)
                    .font(.proRounded(.body, weight: .medium))
                    .lineLimit(1)
                
                if let error = result.error {
                    // Error State
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.proRounded(.caption))
                            .foregroundStyle(.red)
                            .lineLimit(1)
                    }
                } else {
                    // Success State
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
            }
            
            Spacer()
            
            Button(action: {
                NSWorkspace.shared.activateFileViewerSelecting([result.destinationURL])
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Show in Finder")
            
            if result.error != nil {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
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
