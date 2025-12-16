//
//  Components.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit
import Quartz

// Custom rounded font helper
extension Font {
    static func proRounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        return Font.system(style, design: .rounded).weight(weight)
    }
}

// NSViewRepresentable for Visual Effects
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct PremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(Color.accentColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

extension ButtonStyle where Self == PremiumButtonStyle {
    static var premiumAction: PremiumButtonStyle { PremiumButtonStyle() }
}

// Compression Preset Button
struct PresetButton: View {
    let title: String
    let subtitle: String
    let value: Double
    @Binding var currentValue: Double
    
    var isSelected: Bool {
        abs(currentValue - value) < 0.01
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            currentValue = value
        }
    }
}

// Quick Look Comparison Window Manager
class QuickLookComparisonManager {
    static let shared = QuickLookComparisonManager()
    
    func showComparison(original: URL, compressed: URL) {
        // Create a temporary panel to show both files
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        panel.title = "Before & After Comparison"
        panel.isReleasedWhenClosed = false
        panel.center()
        
        // Create split view with both previews
        let splitView = NSSplitView()
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        
        // Original preview
        let originalView = QLPreviewView(frame: .zero, style: .normal)
        originalView?.previewItem = original as QLPreviewItem
        
        // Compressed preview
        let compressedView = QLPreviewView(frame: .zero, style: .normal)
        compressedView?.previewItem = compressed as QLPreviewItem
        
        // Create containers with labels
        let originalContainer = NSStackView()
        originalContainer.orientation = .vertical
        let originalLabel = NSTextField(labelWithString: "Original - \(formatFileSize(original))")
        originalLabel.alignment = .center
        originalLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        originalContainer.addArrangedSubview(originalLabel)
        if let originalView = originalView {
            originalContainer.addArrangedSubview(originalView)
        }
        
        let compressedContainer = NSStackView()
        compressedContainer.orientation = .vertical
        let compressedLabel = NSTextField(labelWithString: "Compressed - \(formatFileSize(compressed))")
        compressedLabel.alignment = .center
        compressedLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        compressedContainer.addArrangedSubview(compressedLabel)
        if let compressedView = compressedView {
            compressedContainer.addArrangedSubview(compressedView)
        }
        
        splitView.addArrangedSubview(originalContainer)
        splitView.addArrangedSubview(compressedContainer)
        
        panel.contentView = splitView
        panel.makeKeyAndOrderFront(nil)
    }
    
    private func formatFileSize(_ url: URL) -> String {
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
            return "Unknown"
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}
