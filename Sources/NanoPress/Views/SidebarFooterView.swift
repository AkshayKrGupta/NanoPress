//
//  SidebarFooterView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI

struct SidebarFooterView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: NanoDesign.Spacing.xs) {
            // Subtle separator
            Rectangle()
                .fill(NanoDesign.separatorColor)
                .frame(height: NanoDesign.Border.separator)
            
            Link("Built with ❤️ by Akshay K Gupta", destination: URL(string: "https://www.linkedin.com/in/akshay-kr-gupta/")!)
                .font(.secondaryText(size: 10))
                .foregroundStyle(.tertiary)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

            Text("Build: 0.5-19.12.2025")
                .font(.secondaryText(size: 10))
                .foregroundStyle(.tertiary)
        }
        .padding(NanoDesign.Spacing.md)
        .background(.ultraThinMaterial)
    }
}

