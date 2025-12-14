import Foundation
import PDFKit
import ImageIO
import UniformTypeIdentifiers
import Quartz

struct CompressionResult: Identifiable, Hashable {
    let id: UUID
    let originalURL: URL
    let destinationURL: URL
    let originalSize: Int64
    let newSize: Int64
    let error: String?
    
    init(originalURL: URL, destinationURL: URL? = nil, originalSize: Int64 = 0, newSize: Int64 = 0, error: String? = nil) {
        self.id = UUID()
        self.originalURL = originalURL
        self.destinationURL = destinationURL ?? originalURL 
        self.originalSize = originalSize
        self.newSize = newSize
        self.error = error
    }
    
    // Hashable conformance for SwiftUI List
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CompressionResult, rhs: CompressionResult) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class CompressionManager: ObservableObject {
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var statusMessage: String = "Ready"
    @Published var completedResults: [CompressionResult] = []
    @Published var completedCount = 0
    
    enum OutputStrategy {
        case specific(URL)
        case sameAsOriginal
    }
    
    // Configuration
    @Published var compressionQuality: Double = 0.8
    
    // Main Workflow
    
    func compressFiles(_ urls: [URL], strategy: OutputStrategy) {
        // Reset State
        self.isProcessing = true
        self.progress = 0.0
        self.completedCount = 0
        self.completedResults = []
        self.statusMessage = "Starting..."
        
        Task {
            let total = Double(urls.count)
            
            for (index, url) in urls.enumerated() {
                self.statusMessage = "Processing \(url.lastPathComponent)..."
                self.progress = Double(index) / total
                
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
                    result = await compressImageType(at: url, to: outputDir)
                } else if fileExtension == "pdf" {
                    result = await compressPDFType(at: url, to: outputDir)
                } else {
                    result = .failure(NSError(domain: "NanoPressError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unsupported format"]))
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
                
                self.completedResults.append(res)
                
                self.completedCount += 1
            }
            
            // Finalize
            self.statusMessage = "Batch Complete"
            self.progress = 1.0
            self.isProcessing = false
        }
    }
    
    // Image Compression
    
    private func compressImageType(at url: URL, to outputDir: URL) async -> Result<URL, Error> {
        return await Task.detached(priority: .userInitiated) { [compressionQuality] () -> Result<URL, Error> in
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                return .failure(NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not read source image"]))
            }
            
            let filename = url.deletingPathExtension().lastPathComponent
            let ext = url.pathExtension
            let destURL: URL
            
            if outputDir == url.deletingLastPathComponent() {
                destURL = outputDir.appendingPathComponent(filename + "_compressed." + ext)
            } else {
                destURL = outputDir.appendingPathComponent(url.lastPathComponent)
            }
            
            // Identify correct type
            guard let utType = UTType(filenameExtension: ext),
                  let destination = CGImageDestinationCreateWithURL(destURL as CFURL, utType.identifier as CFString, 1, nil) else {
                return .failure(NSError(domain: "ImageError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create destination"]))
            }
            
            let options: [String: Any] = [
                kCGImageDestinationLossyCompressionQuality as String: compressionQuality,
                kCGImageDestinationOptimizeColorForSharing as String: true
            ]
            
            CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
            
            if CGImageDestinationFinalize(destination) {
                return .success(destURL)
            } else {
                return .failure(NSError(domain: "ImageError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Compression failed"]))
            }
        }.value
    }
    
    // PDF Compression
    
    private func compressPDFType(at url: URL, to outputDir: URL) async -> Result<URL, Error> {
        return await Task.detached(priority: .userInitiated) { () -> Result<URL, Error> in
            let filename = url.deletingPathExtension().lastPathComponent
            let destURL: URL
            
            if outputDir == url.deletingLastPathComponent() {
                destURL = outputDir.appendingPathComponent(filename + "_compressed.pdf")
            } else {
                destURL = outputDir.appendingPathComponent(url.lastPathComponent)
            }
            
            guard let pdfDoc = PDFDocument(url: url) else {
                return .failure(NSError(domain: "PDFError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF"]))
            }
            
            guard let context = CGContext(destURL as CFURL, mediaBox: nil, nil) else {
                 return .failure(NSError(domain: "PDFError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create PDF Context"]))
            }
            
           
            for i in 0..<pdfDoc.pageCount {
                guard let page = pdfDoc.page(at: i) else { continue }
                var mediaBox = page.bounds(for: .mediaBox)
                let data = Data(bytes: &mediaBox, count: MemoryLayout<CGRect>.size) as CFData
                let pageInfo = [kCGPDFContextMediaBox as String: data] as CFDictionary
                context.beginPDFPage(pageInfo)
                context.saveGState()

                // Draw the page
                page.draw(with: .mediaBox, to: context)

                context.restoreGState()
                context.endPDFPage()
            }
            
            context.closePDF()
            
            
            
            return .success(destURL)
        }.value
    }
}
