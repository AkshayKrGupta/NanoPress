//
//  PDFCompression.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import Foundation
import PDFKit
import Quartz

/// Extension for handling PDF compression with standard and aggressive modes
extension CompressionManager {
    
    func compressPDFType(at url: URL, to outputDir: URL, mode: PDFCompressionMode) async -> Result<URL, AppError> {
        switch mode {
        case .standard:
            return await compressPDFStandard(at: url, to: outputDir)
        case .aggressive:
            return await compressPDFAggressive(at: url, to: outputDir)
        }
    }
    
    // Standard PDF Compression
    
    /// Standard compression using Quartz filter only - balanced quality and size
    private func compressPDFStandard(at url: URL, to outputDir: URL) async -> Result<URL, AppError> {
        return await Task.detached(priority: .userInitiated) { () -> Result<URL, AppError> in
            let filename = url.deletingPathExtension().lastPathComponent
            let destURL: URL
            
            if outputDir == url.deletingLastPathComponent() {
                destURL = outputDir.appendingPathComponent(filename + "_compressed.pdf")
            } else {
                destURL = outputDir.appendingPathComponent(url.lastPathComponent)
            }
            
            guard let pdfDoc = PDFDocument(url: url) else {
                return .failure(.invalidInput(url.lastPathComponent))
            }
            
            // Get original file size
            let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            
            // Load Quartz Filter
            let filterPath = "/System/Library/Filters/Reduce File Size.qfilter"
            let filterURL = URL(fileURLWithPath: filterPath)
            
            var options: [PDFDocumentWriteOption: Any] = [:]
            if let filter = QuartzFilter(url: filterURL) {
                options[PDFDocumentWriteOption(rawValue: "QuartzFilter")] = filter
            }
            
            // Apply Filter and Save
            guard pdfDoc.write(to: destURL, withOptions: options) else {
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
    
    // Aggressive PDF Compression
    
    /// Aggressive compression with multi-pass optimization - maximum size reduction
    private func compressPDFAggressive(at url: URL, to outputDir: URL) async -> Result<URL, AppError> {
        return await Task.detached(priority: .userInitiated) { () -> Result<URL, AppError> in
            let filename = url.deletingPathExtension().lastPathComponent
            let destURL: URL
            
            if outputDir == url.deletingLastPathComponent() {
                destURL = outputDir.appendingPathComponent(filename + "_compressed.pdf")
            } else {
                destURL = outputDir.appendingPathComponent(url.lastPathComponent)
            }
            
            guard let pdfDoc = PDFDocument(url: url) else {
                return .failure(.invalidInput(url.lastPathComponent))
            }
            
            // Get original file size
            let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            
            // Create temporary files for comparison
            let tempURL1 = FileManager.default.temporaryDirectory.appendingPathComponent("temp1_\(UUID().uuidString).pdf")
            let tempURL2 = FileManager.default.temporaryDirectory.appendingPathComponent("temp2_\(UUID().uuidString).pdf")
            
            // Load Quartz Filter
            let filterPath = "/System/Library/Filters/Reduce File Size.qfilter"
            let filterURL = URL(fileURLWithPath: filterPath)
            
            // First pass: Apply filter with metadata stripping
            var firstPassOptions: [PDFDocumentWriteOption: Any] = [:]
            
            if let filter = QuartzFilter(url: filterURL) {
                firstPassOptions[PDFDocumentWriteOption(rawValue: "QuartzFilter")] = filter
            }
            
            // Strip metadata aggressively
            firstPassOptions[.ownerPasswordOption] = ""
            firstPassOptions[.userPasswordOption] = ""
            
            // Save first pass
            guard pdfDoc.write(to: tempURL1, withOptions: firstPassOptions) else {
                return .failure(.saveFailed)
            }
            
            let firstPassSize = (try? FileManager.default.attributesOfItem(atPath: tempURL1.path)[.size] as? Int64) ?? 0
            
            // Decide if second pass is worth it (only if first pass achieved >10% reduction)
            let reductionPercent = Double(originalSize - firstPassSize) / Double(originalSize)
            var finalURL = tempURL1
            var shouldTrySecondPass = reductionPercent > 0.1 && firstPassSize > 100_000 // Only for larger files that showed reduction
            
            if shouldTrySecondPass {
                // Second pass: Try to compress again
                guard let optimizedDoc = PDFDocument(url: tempURL1) else {
                    try? FileManager.default.removeItem(at: tempURL1)
                    return .failure(.pdfCreationError)
                }
                
                var secondPassOptions: [PDFDocumentWriteOption: Any] = [:]
                
                if let filter = QuartzFilter(url: filterURL) {
                    secondPassOptions[PDFDocumentWriteOption(rawValue: "QuartzFilter")] = filter
                }
                
                // Apply again
                if optimizedDoc.write(to: tempURL2, withOptions: secondPassOptions) {
                    let secondPassSize = (try? FileManager.default.attributesOfItem(atPath: tempURL2.path)[.size] as? Int64) ?? Int64.max
                    
                    // Only use second pass if it's actually smaller
                    if secondPassSize < firstPassSize {
                        finalURL = tempURL2
                        try? FileManager.default.removeItem(at: tempURL1)
                    } else {
                        try? FileManager.default.removeItem(at: tempURL2)
                    }
                } else {
                    // Second pass failed, use first pass
                    try? FileManager.default.removeItem(at: tempURL2)
                }
            }
            
            // Move final result to destination
            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.moveItem(at: finalURL, to: destURL)
            } catch {
                try? FileManager.default.removeItem(at: tempURL1)
                try? FileManager.default.removeItem(at: tempURL2)
                return .failure(.saveFailed)
            }
            
            // Clean up any remaining temp files
            try? FileManager.default.removeItem(at: tempURL1)
            try? FileManager.default.removeItem(at: tempURL2)
            
            // Check if compressed file is actually smaller than original
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
