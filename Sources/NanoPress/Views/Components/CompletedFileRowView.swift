//
//  CompletedFileRowView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit

struct CompletedFileRowView: View {
    let result: CompressionResult
    
    var body: some View {
        HStack(spacing: NanoDesign.Spacing.lg) {
            ThumbnailView(url: result.originalURL) 
            
            VStack(alignment: .leading, spacing: NanoDesign.Spacing.xs) {
                Text(result.originalURL.lastPathComponent)
                    .font(.bodyMedium)
                    .lineLimit(1)
                
                if let error = result.error {
                    // Error State
                    HStack(spacing: NanoDesign.Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .uiIconStyle()
                            .foregroundStyle(NanoDesign.destructive)
                        Text(error)
                            .font(.secondaryText(size: 11))
                            .foregroundStyle(NanoDesign.destructive)
                            .lineLimit(1)
                    }
                } else {
                    // Success State
                    HStack(spacing: NanoDesign.Spacing.sm) {
                        Text(formatBytes(result.originalSize))
                            .font(.secondaryText(size: 11))
                            .strikethrough(true)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            
                        Text(formatBytes(result.newSize))
                            .font(.secondaryText(size: 12))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    
                        if result.originalSize > 0 {
                            let saving = Double(result.originalSize - result.newSize) / Double(result.originalSize) * 100
                            Text("(-\(Int(saving))%)")
                                .font(.secondaryText(size: 11))
                                .foregroundStyle(saving > 0 ? NanoDesign.success : .orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action buttons with UI icon styling
            HStack(spacing: NanoDesign.Spacing.sm) {
                Button(action: {
                    QuickLookComparisonManager.shared.showComparison(
                        original: result.originalURL,
                        compressed: result.destinationURL
                    )
                }) {
                    Image(systemName: "rectangle.split.2x1")
                        .uiIconStyle()
                        .foregroundStyle(.purple)
                }
                .buttonStyle(.plain)
                .help("Compare Before/After")
                
                Button(action: {
                    NSWorkspace.shared.open(result.destinationURL)
                }) {
                    Image(systemName: "eye.fill")
                        .uiIconStyle()
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .help("Preview")
                
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([result.destinationURL])
                }) {
                    Image(systemName: "magnifyingglass")
                        .uiIconStyle()
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Show in Finder")
            }
            
            // Status icon with hierarchical rendering
            if result.error != nil {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(NanoDesign.destructive)
                    .font(.system(size: 18, weight: .medium))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(NanoDesign.success)
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .padding(NanoDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.large)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.large)
                        .strokeBorder(NanoDesign.separatorColor, lineWidth: NanoDesign.Border.separator)
                )
                .shadow(
                    color: .black.opacity(NanoDesign.Shadow.cardOpacity),
                    radius: NanoDesign.Shadow.cardRadius,
                    x: 0,
                    y: NanoDesign.Shadow.cardY
                )
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
