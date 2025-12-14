import SwiftUI

struct SidebarFooterView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider()
                .padding(.bottom, 8)
            

            
            Link("Built with ❤️ by Akshay K Gupta", destination: URL(string: "https://www.linkedin.com/in/akshay-kr-gupta/")!)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

            Text("Last Build Date: 14 Dec 2025")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial)
    }
}
