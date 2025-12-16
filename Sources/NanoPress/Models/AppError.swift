//
//  AppError.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import Foundation

enum AppError: LocalizedError {
    case invalidInput(String)
    case accessDenied
    case unsupportedFormat(String)
    case conversionFailed
    case saveFailed
    case emptyImage
    case pdfCreationError
    case quartzFilterMissing
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidInput(let name):
            return "Could not read the file '\(name)'. It might be corrupted."
        case .accessDenied:
            return "Access denied. Please check your file permissions."
        case .unsupportedFormat(let ext):
            return "The file extension '.\(ext)' is not supported."
        case .conversionFailed:
            return "We couldn't compress this file properly."
        case .saveFailed:
            return "Failed to save the compressed file."
        case .emptyImage:
            return "The image appears to be empty or invalid."
        case .pdfCreationError:
            return "Could not process the PDF page."
        case .quartzFilterMissing:
            return "The system compression filter could not be found."
        case .unknown(let msg):
            return "An unexpected error occurred: \(msg)"
        }
    }
}
