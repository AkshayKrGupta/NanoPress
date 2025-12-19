//
//  StatusBarView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI

struct StatusBarView: View {
    let progress: Double
    let statusMessage: String
    let completedCount: Int
    let totalCount: Int
    
    var body: some View {
        HStack(spacing: NanoDesign.Spacing.lg) {
            // Processing Indicator or Icon
            if progress < 1.0 && progress > 0.0 {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .frame(width: 80)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(progress >= 1.0 ? NanoDesign.success : .secondary)
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Status Text
            VStack(alignment: .leading, spacing: 2) {
                Text(statusMessage)
                    .font(.secondaryText(size: 12))
                    .fontWeight(.medium)
                
                if totalCount > 0 {
                    Text("\(completedCount) of \(totalCount) items completed")
                        .font(.secondaryText(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .layoutPriority(1)
            
            Spacer()
            
            Link("© 2025 NanoPress v0.5-beta", destination: URL(string: "https://github.com/AkshayKrGupta/NanoPress")!)
                .font(.secondaryText(size: 10))
                .foregroundStyle(.secondary)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
        }
        .padding(.horizontal, NanoDesign.Spacing.lg)
        .padding(.vertical, NanoDesign.Spacing.md)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: NanoDesign.Border.separator)
                .foregroundColor(NanoDesign.separatorColor),
            alignment: .top
        )
    }
}

#Preview {
    ZStack {
        Color.gray
        StatusBarView(progress: 0.4, statusMessage: "Compressing Image.png", completedCount: 2, totalCount: 5)
    }
}
