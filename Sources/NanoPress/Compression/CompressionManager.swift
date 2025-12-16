import Foundation
import SwiftUI

/// Main manager class for handling file compression operations
@MainActor
class CompressionManager: ObservableObject {
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var statusMessage: String = "Ready"
    @Published var completedResults: [CompressionResult] = []
    @Published var completedCount = 0
    @Published var currentProcessingURL: URL? = nil
    
    enum OutputStrategy {
        case specific(URL)
        case sameAsOriginal
    }
    
    // Configuration
    @Published var compressionQuality: Double = 0.8
    @Published var pdfCompressionMode: PDFCompressionMode = .standard
    
    // Cancellation support
    private var compressionTask: Task<Void, Never>?
    private var isCancelled = false
    
    // Main Workflow
    
    func compressFiles(_ urls: [URL], strategy: OutputStrategy) {
        // Reset State
        self.isProcessing = true
        self.progress = 0.0
        self.completedCount = 0
        self.completedResults = []
        self.statusMessage = "Starting..."
        self.currentProcessingURL = nil
        self.isCancelled = false
        
        // Cancel any existing task
        compressionTask?.cancel()
        
        compressionTask = Task { @MainActor in
            let total = urls.count
            
            // Process files in parallel - max 4 concurrent
            await withTaskGroup(of: (Int, CompressionResult).self) { group in
                for (index, url) in urls.enumerated() {
                    // Check cancellation
                    if self.isCancelled || Task.isCancelled {
                        break
                    }
                    
                    // Limit concurrent tasks to 4
                    if index >= 4 {
                        // Wait for one to complete before adding more
                        if let (completedIndex, result) = await group.next() {
                            self.handleCompletedResult(result, index: completedIndex, total: total)
                        }
                    }
                    
                    group.addTask {
                        await self.compressFile(url, strategy: strategy, index: index)
                    }
                }
                
                // Collect remaining results
                for await (completedIndex, result) in group {
                    if self.isCancelled || Task.isCancelled {
                        break
                    }
                    self.handleCompletedResult(result, index: completedIndex, total: total)
                }
            }
            
            await MainActor.run {
                if self.isCancelled || Task.isCancelled {
                    self.statusMessage = "Cancelled"
                } else {
                    self.statusMessage = "Batch Complete"
                }
                self.progress = 1.0
                self.isProcessing = false
                self.currentProcessingURL = nil
            }
        }
    }
    
    func cancelCompression() {
        isCancelled = true
        compressionTask?.cancel()
        statusMessage = "Cancelling..."
    }
    
    @MainActor
    private func handleCompletedResult(_ result: CompressionResult, index: Int, total: Int) {
        self.completedResults.append(result)
        self.completedCount += 1
        self.progress = Double(self.completedCount) / Double(total)
        
        if result.error == nil {
            self.statusMessage = "Completed \(result.originalURL.lastPathComponent)"
        }
    }
    
    // File Processing
    
    private func compressFile(_ url: URL, strategy: OutputStrategy, index: Int) async -> (Int, CompressionResult) {
        // Update current processing
        await MainActor.run {
            self.currentProcessingURL = url
            self.statusMessage = "Processing \(url.lastPathComponent)..."
        }
        
        // Determine Output Directory
        let outputDir: URL
        switch strategy {
        case .specific(let dir): outputDir = dir
        case .sameAsOriginal: outputDir = url.deletingLastPathComponent()
        }
        
        // Capture original size
        let originalSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).flatMap { Int64($0) } ?? 0
        
        // Process File
        let fileExtension = url.pathExtension.lowercased()
        let result: Result<URL, Error>
        
        if ["jpg", "jpeg", "png", "heic", "tif", "tiff"].contains(fileExtension) {
            let res = await compressImageType(at: url, to: outputDir)
            switch res {
            case .success(let u): result = .success(u)
            case .failure(let e): result = .failure(e)
            }
        } else if fileExtension == "pdf" {
            let mode = await MainActor.run { self.pdfCompressionMode }
            let res = await compressPDFType(at: url, to: outputDir, mode: mode)
            switch res {
            case .success(let u): result = .success(u)
            case .failure(let e): result = .failure(e)
            }
        } else {
            result = .failure(AppError.unsupportedFormat(fileExtension))
        }
        
        // Handle Result
        let res: CompressionResult
        switch result {
        case .success(let destURL):
            let newSize = (try? destURL.resourceValues(forKeys: [.fileSizeKey]).fileSize).flatMap { Int64($0) } ?? 0
            res = CompressionResult(
                originalURL: url,
                destinationURL: destURL,
                originalSize: originalSize,
                newSize: newSize
            )
        case .failure(let error):
            res = CompressionResult(
                originalURL: url,
                originalSize: originalSize,
                error: error.localizedDescription
            )
        }
        
        return (index, res)
    }
}
