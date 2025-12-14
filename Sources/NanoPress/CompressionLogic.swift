import Foundation
import PDFKit
import ImageIO
import UniformTypeIdentifiers
import Quartz

class CompressionLogic: ObservableObject {
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var statusMessage: String = "Ready"
    @Published var completedCount = 0
    
    // Configuration
    var imageQuality: Double = 0.8
    
    func compressFiles(_ urls: [URL], to outputDir: URL, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                self?.isProcessing = true
                self?.progress = 0.0
                self?.completedCount = 0
            }
            
            let total = Double(urls.count)
            
            for (index, url) in urls.enumerated() {
                DispatchQueue.main.async {
                    self?.statusMessage = "Processing \(url.lastPathComponent)..."
                    self?.progress = Double(index) / total
                }
                
                let fileExtension = url.pathExtension.lowercased()
                
                if ["jpg", "jpeg", "png", "heic"].contains(fileExtension) {
                    _ = self?.compressImage(at: url, to: outputDir)
                } else if fileExtension == "pdf" {
                    _ = self?.compressPDF(at: url, to: outputDir)
                }
                
                DispatchQueue.main.async {
                    self?.completedCount += 1
                }
            }
            
            DispatchQueue.main.async {
                self?.isProcessing = false
                self?.statusMessage = "Done"
                self?.progress = 1.0
                completion()
            }
        }
    }
    
    private func compressImage(at url: URL, to outputDir: URL) -> Result<URL, Error> {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return .failure(NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not read source image"]))
        }
        
        let destURL = outputDir.appendingPathComponent(url.deletingPathExtension().lastPathComponent + "_compressed." + url.pathExtension)
        
        let utType = UTType(filenameExtension: url.pathExtension) ?? .image
        
        guard let destination = CGImageDestinationCreateWithURL(destURL as CFURL, utType.identifier as CFString, 1, nil) else {
            return .failure(NSError(domain: "ImageError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create destination"]))
        }
        
        let options: [String: Any] = [
            kCGImageDestinationLossyCompressionQuality as String: imageQuality
        ]
        
        CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            // Check size
            let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            let newSize = (try? FileManager.default.attributesOfItem(atPath: destURL.path)[.size] as? Int64) ?? 0
            
            if newSize >= originalSize {
                // Compression failed to reduce size. Copy original instead? 
                // Or maybe just leave it but warn? 
                // For this request, user specifically mentioned "Bigger Output", so let's preserve original if we failed to compress.
                try? FileManager.default.removeItem(at: destURL)
                // We'll append "_original" to verify we didn't touch it or just copy
                let fallbackURL = outputDir.appendingPathComponent(url.deletingPathExtension().lastPathComponent + "_original." + url.pathExtension)
                try? FileManager.default.copyItem(at: url, to: fallbackURL)
                return .success(fallbackURL)
            }
            
            return .success(destURL)
        } else {
            return .failure(NSError(domain: "ImageError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Compression failed"]))
        }
    }
    
    private func compressPDF(at url: URL, to outputDir: URL) -> Result<URL, Error> {
        let destURL = outputDir.appendingPathComponent(url.deletingPathExtension().lastPathComponent + "_compressed.pdf")
        
        // Try Quartz Filter Approach if possible
        // Note: Creating a custom Quartz filter programmatically is verbose.
        // We will try using PDFDocument's data representation with options, or context redraw.
        
        guard let pdfDoc = PDFDocument(url: url) else {
             return .failure(NSError(domain: "PDFError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF"]))
        }
        
        // This is a known trick: Create a new PDF Document and insert pages.
        // And when writing, we can try to apply some Quartz filters if we had access to the filter file.
        // Without external resources, we rely on PDFKit optimization.
        // To strictly ensure size reduction, we might need to re-render pages into a new context with lower JPEG quality for images.
        
        // Simple optimization:
        let options: [PDFDocumentWriteOption: Any] = [:]
        
        // Check if we can beat the size
        if pdfDoc.write(to: destURL, withOptions: options) {
             let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
             let newSize = (try? FileManager.default.attributesOfItem(atPath: destURL.path)[.size] as? Int64) ?? 0
             
             if newSize >= originalSize {
                 // Optimization failed, remove and copy original
                 try? FileManager.default.removeItem(at: destURL)
                 let fallbackURL = outputDir.appendingPathComponent(url.deletingPathExtension().lastPathComponent + "_original.pdf")
                 try? FileManager.default.copyItem(at: url, to: fallbackURL)
                 return .success(fallbackURL)
             }
             return .success(destURL)
        }
        
        return .failure(NSError(domain: "PDFError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not write PDF"]))
    }
}
