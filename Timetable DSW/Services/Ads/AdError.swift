//
//  AdError.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import Foundation

enum AdError: Error, LocalizedError {
    case notLoaded
    case failedToLoad(Error)
    case failedToPresent(Error)
    case premiumUser
    case adsDisabled
    case noReward
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .notLoaded: return "Ad not loaded yet"
        case .failedToLoad(let error): return "Failed to load: \(error.localizedDescription)"
        case .failedToPresent(let error): return "Failed to present: \(error.localizedDescription)"
        case .premiumUser: return "Ads disabled for premium users"
        case .adsDisabled: return "Ads are currently disabled"
        case .noReward: return "Ad closed before reward"
        case .timeout: return "Operation timeout"
        }
    }
}
