//
//  ImageCompression.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Extension for handling image compression
extension CompressionManager {
    
    func compressImageType(at url: URL, to outputDir: URL) async -> Result<URL, AppError> {
        return await Task.detached(priority: .userInitiated) { [compressionQuality] () -> Result<URL, AppError> in
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                return .failure(.invalidInput(url.lastPathComponent))
            }
            
            let filename = url.deletingPathExtension().lastPathComponent
            let ext = url.pathExtension
            let destURL: URL
            
            if outputDir == url.deletingLastPathComponent() {
                destURL = outputDir.appendingPathComponent(filename + "_compressed." + ext)
            } else {
                destURL = outputDir.appendingPathComponent(url.lastPathComponent)
            }
            
            // Get original file size
            let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            
            // Identify correct type
            guard let utType = UTType(filenameExtension: ext),
                  let destination = CGImageDestinationCreateWithURL(destURL as CFURL, utType.identifier as CFString, 1, nil) else {
                return .failure(.conversionFailed)
            }
            
            let options: [String: Any] = [
                kCGImageDestinationLossyCompressionQuality as String: compressionQuality,
                kCGImageDestinationOptimizeColorForSharing as String: true
            ]
            
            CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
            
            guard CGImageDestinationFinalize(destination) else {
                return .failure(.saveFailed)
            }
            
            // Check if compressed file is actually smaller
            let compressedSize = (try? FileManager.default.attributesOfItem(atPath: destURL.path)[.size] as? Int64) ?? 0
            
            if compressedSize >= originalSize {
                // Compressed version is larger or same size - copy original instead
                try? FileManager.default.removeItem(at: destURL)
                try? FileManager.default.copyItem(at: url, to: destURL)
            }
            
            return .success(destURL)
        }.value
    }
}
