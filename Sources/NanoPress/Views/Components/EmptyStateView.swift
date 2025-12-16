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
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .strokeBorder(isDraggingOver ? Color.accentColor : Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .background(Circle().fill(isDraggingOver ? Color.accentColor.opacity(0.1) : Color.clear))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isDraggingOver ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDraggingOver)
                
                // App Logo or Symbol
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(isDraggingOver ? Color.accentColor : .secondary)
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
