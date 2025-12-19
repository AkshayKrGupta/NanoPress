//
//  FileRowView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit

struct FileRowView: View {
    let url: URL
    let isProcessing: Bool
    let isSelected: Bool
    let onRemove: () -> Void
    let onSelect: () -> Void
    @State private var thumbnail: NSImage? = nil
    
    var body: some View {
        HStack(spacing: NanoDesign.Spacing.lg) {
            ThumbnailView(url: url)
            
            VStack(alignment: .leading, spacing: NanoDesign.Spacing.xs) {
                Text(url.lastPathComponent)
                    .font(.bodyMedium)
                    .lineLimit(1)
                
                Text(formatSize(url))
                    .font(.secondaryText(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isProcessing {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .uiIconStyle()
                        .foregroundStyle(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(NanoDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.large)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.large)
                        .strokeBorder(
                            isSelected ? Color.accentColor : NanoDesign.separatorColor,
                            lineWidth: isSelected ? 2 : NanoDesign.Border.separator
                        )
                )
                .shadow(
                    color: .black.opacity(NanoDesign.Shadow.cardOpacity),
                    radius: NanoDesign.Shadow.cardRadius,
                    x: 0,
                    y: NanoDesign.Shadow.cardY
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(
            color: isSelected ? Color.accentColor.opacity(0.2) : .clear,
            radius: isSelected ? 6 : 0
        )
        .animation(.selectionSpring, value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
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
