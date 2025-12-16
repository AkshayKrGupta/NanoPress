//
//  ThumbnailView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit
import QuickLookThumbnailing

struct ThumbnailView: View {
    let url: URL
    @State private var thumbnail: NSImage?
    
    var body: some View {
        Group {
            if let thumb = thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: 40, height: 40)
        .cornerRadius(4)
        .onAppear {
             loadThumbnail()
        }
    }
    
    func loadThumbnail() {
        // Check cache first
        if let cached = ThumbnailCache.shared.get(for: url) {
            self.thumbnail = cached
            return
        }
        
        // Generate if not cached
        generateThumbnail()
    }
    
    func generateThumbnail() {
        let size = CGSize(width: 80, height: 80)
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .thumbnail)
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
            if let thumbnail = thumbnail {
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail.nsImage
                    // Cache for future use
                    ThumbnailCache.shared.set(thumbnail.nsImage, for: self.url)
                }
            }
        }
    }
}
