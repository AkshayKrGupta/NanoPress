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
            
            if isProcessing {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        )
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
