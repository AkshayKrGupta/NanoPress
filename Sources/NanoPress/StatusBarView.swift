import SwiftUI

struct StatusBarView: View {
    let progress: Double
    let statusMessage: String
    let completedCount: Int
    let totalCount: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Processing Indicator or Icon
            if progress < 1.0 && progress > 0.0 {
                ProgressView()
                    .controlSize(.small)
                    .progressViewStyle(.circular)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(progress >= 1.0 ? .green : .secondary)
            }
            
            // Status Text
            VStack(alignment: .leading, spacing: 2) {
                Text(statusMessage)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if totalCount > 0 {
                    Text("\(completedCount) of \(totalCount) items completed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .layoutPriority(1)
            
            Spacer()
            
            // Progress Bar
            if totalCount > 0 {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .frame(width: 100)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Material.bar)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .top
        )
    }
}

#Preview {
    StatusBarView(progress: 0.4, statusMessage: "Compressing Image.png", completedCount: 2, totalCount: 5)
}
