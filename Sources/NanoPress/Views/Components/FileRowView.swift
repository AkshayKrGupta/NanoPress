import SwiftUI
import AppKit

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
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
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
