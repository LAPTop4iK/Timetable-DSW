//
//  NetworkError.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return LocalizedString.errorInvalidURL.localized
        case .invalidResponse:
            return LocalizedString.errorInvalidResponse.localized
        case .httpError(let code):
            return "\(LocalizedString.errorServer.localized) (\(code))"
        }
    }
}
