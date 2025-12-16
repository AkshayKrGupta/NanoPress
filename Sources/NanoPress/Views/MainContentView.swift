//
//  MainContentView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit

struct MainContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {

        ZStack(alignment: .top) {

            // Background
            ZStack {
                // Base Glass Blur
                VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                
                // Adaptive Gradient Tint
                if colorScheme == .dark {
                    // Dark Mode: Deep Purple/Blue
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.0, blue: 0.4).opacity(0.15), // Deep Purple
                            Color(red: 0.0, green: 0.2, blue: 0.5).opacity(0.10), // Deep Blue
                            Color.black.opacity(0.2) // Slight darkening for contrast
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    // Light Mode: Airy/Clean
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5), // Whitewash top-left
                            Color(red: 0.9, green: 0.95, blue: 1.0).opacity(0.3), // Pale Blue
                            Color(red: 0.95, green: 0.9, blue: 1.0).opacity(0.2)  // Pale Lavender
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                HStack(spacing: 16) {
                     if let imagePath = Bundle.module.path(forResource: "AppIcon", ofType: "png"),
                        let nsImage = NSImage(contentsOfFile: imagePath) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .frame(width: 48, height: 48)
                     }
                     Text("NanoPress")
                         .font(.system(size: 32, weight: .bold, design: .rounded))
                     Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(.ultraThinMaterial)
                
                if !viewModel.compressor.completedResults.isEmpty && !viewModel.compressor.isProcessing {
                    // Completed View
                    VStack {
                        HStack {
                            Text("Compression Complete")
                                .font(.proRounded(.title2, weight: .bold))
                            Spacer()
                        }
                        .padding()
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.compressor.completedResults, id: \.self) { result in
                                    CompletedFileRowView(result: result)
                                        .transition(.opacity)
                                }
                            }
                            .padding()
                        }
                        
                        // Bottom Action Bar
                        Divider()
                            .background(Color.secondary.opacity(0.2))
                        HStack {
                            Button(action: {
                                viewModel.compressor.completedResults.removeAll()
                                viewModel.pendingFiles.removeAll()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Done / Start New Batch")
                                        .font(.proRounded(.headline))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                            }
                            .buttonStyle(.premiumAction)
                            .controlSize(.large)
                            .padding()
                        }
                        .background(.regularMaterial)
                    }
                    .transition(.opacity)
                } else if viewModel.pendingFiles.isEmpty {
                    // Empty State
                    EmptyStateView(isDraggingOver: viewModel.isDraggingOver, onBrowse: viewModel.selectFiles)
                        .frame(maxHeight: .infinity)
                        .transition(.opacity)
                } else {
                    // File List
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.pendingFiles, id: \.self) { url in
                                    FileRowView(
                                        url: url,
                                        isProcessing: viewModel.compressor.currentProcessingURL == url,
                                        isSelected: viewModel.selectedFiles.contains(url),
                                        onRemove: {
                                            withAnimation {
                                                if let index = viewModel.pendingFiles.firstIndex(of: url) {
                                                    viewModel.pendingFiles.remove(at: index)
                                                    viewModel.selectedFiles.remove(url)
                                                }
                                            }
                                        },
                                        onSelect: {
                                            let modifiers = NSEvent.modifierFlags
                                            viewModel.toggleFileSelection(url, modifiers: modifiers)
                                        }
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                }
                                
                                Button(action: viewModel.selectFiles) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add More Files")
                                    }
                                    .font(.proRounded(.body, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .foregroundStyle(.tertiary)
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 8)
                            }
                            .padding()
                        }
                        
                        // Main Compress Button
                        if !viewModel.compressor.isProcessing {
                            Divider()
                                .background(Color.secondary.opacity(0.2))
                            HStack {
                                Button(action: viewModel.startCompression) {
                                    HStack {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("Compress Files")
                                            .font(.proRounded(.headline))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                }
                                .buttonStyle(.premiumAction)
                                .controlSize(.large)
                                .padding()
                            }
                            .background(.regularMaterial)
                        } else {
                            // Cancel button when processing
                            Divider()
                                .background(Color.secondary.opacity(0.2))
                            HStack {
                                Button(action: {
                                    viewModel.compressor.cancelCompression()
                                }) {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Cancel")
                                            .font(.proRounded(.headline))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                                .controlSize(.large)
                                .padding()
                            }
                            .background(.regularMaterial)
                        }
                    }
                    .transition(.opacity)
                }
                
                // Permanent Status Bar
                StatusBarView(
                    progress: viewModel.compressor.progress,
                    statusMessage: viewModel.compressor.statusMessage,
                    completedCount: viewModel.compressor.completedCount,
                    totalCount: viewModel.pendingFiles.count
                )
            }
            
            // Notification Banner
            if viewModel.showNotification {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: viewModel.isErrorNotification ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundStyle(viewModel.isErrorNotification ? .red : .green)
                            .font(.title3)
                        Text(viewModel.notificationMessage)
                            .font(.proRounded(.body, weight: .medium))
                            
                        if !viewModel.isErrorNotification {
                            Button("Show in Finder") {
                                let urls = viewModel.compressor.completedResults.map { $0.destinationURL }
                                if !urls.isEmpty {
                                    NSWorkspace.shared.activateFileViewerSelecting(urls)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(maxWidth: 400)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $viewModel.isDraggingOver) { providers in
            viewModel.handleDrop(providers: providers)
            return true
        }
        .onAppear {
            // Set up keyboard monitoring
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                viewModel.handleKeyCommand(event.characters ?? "", modifiers: event.modifierFlags)
                return event
            }
        }
        .onChange(of: viewModel.compressor.isProcessing) { _, newValue in
            if !newValue && !viewModel.compressor.completedResults.isEmpty {
                // Show Notification
                let savings = viewModel.compressor.completedResults.reduce(0) { $0 + ($1.originalSize - $1.newSize) }
                let mbSaved = String(format: "%.1f MB", Double(savings) / 1024.0 / 1024.0)
                viewModel.notificationMessage = "Batch Complete! Saved \(mbSaved)"
                withAnimation(.spring()) {
                    viewModel.showNotification = true
                }
                
                // Dismiss after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        viewModel.showNotification = false
                    }
                }
            }
        }
    }
}
