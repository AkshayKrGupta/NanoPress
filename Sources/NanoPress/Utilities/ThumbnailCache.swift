//
//  ThumbnailCache.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import Foundation
import AppKit

/// Singleton cache for storing generated thumbnails to improve UI performance
class ThumbnailCache {
    static let shared = ThumbnailCache()
    
    private let cache = NSCache<NSURL, NSImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Max 100 thumbnails
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func get(for url: URL) -> NSImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func set(_ image: NSImage, for url: URL) {
        // Calculate approximate cost (width * height * 4 bytes per pixel)
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
    
    func remove(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}
