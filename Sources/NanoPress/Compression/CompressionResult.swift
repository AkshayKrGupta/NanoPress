import Foundation

/// Result of a file compression operation
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
