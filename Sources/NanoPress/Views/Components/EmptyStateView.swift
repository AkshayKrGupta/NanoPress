//
//  EmptyStateView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit

struct EmptyStateView: View {
    var isDraggingOver: Bool
    var onBrowse: () -> Void
    
    var body: some View {
        VStack(spacing: NanoDesign.Spacing.xl) {
            ZStack {
                Circle()
                    .strokeBorder(
                        isDraggingOver ? Color.accentColor : NanoDesign.separatorColor,
                        style: StrokeStyle(lineWidth: 2, dash: [10])
                    )
                    .background(
                        Circle()
                            .fill(isDraggingOver ? Color.accentColor.opacity(0.1) : Color.clear)
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(isDraggingOver ? 1.05 : 1.0)
                    .animation(.selectionSpring, value: isDraggingOver)
                
                // Hero Icon: 70pt light weight with hierarchical rendering
                Image(systemName: "square.and.arrow.down")
                    .heroIconStyle(size: 70)
                    .foregroundStyle(isDraggingOver ? NanoDesign.accentGradient : LinearGradient(colors: [.secondary], startPoint: .leading, endPoint: .trailing))
            }
            
            VStack(spacing: NanoDesign.Spacing.md) {
                Text("Drop Files Here")
                    .font(.sectionHeader(size: 24))
                
                Text("— or —")
                    .foregroundStyle(.secondary)
                    .font(.secondaryText(size: 12))
                
                Button("Browse Files") {
                     onBrowse()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("Supports JPG, PNG, HEIC, TIFF, and PDF")
                    .font(.secondaryText(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.top, NanoDesign.Spacing.sm)
            }
        }
    }
}

