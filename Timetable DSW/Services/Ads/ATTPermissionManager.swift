//
//  ATTPermissionManager.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 24/10/2025.
//

import AppTrackingTransparency

enum ATTPermissionManager {
    @MainActor
    static func requestIfNeeded() async -> ATTrackingManager.AuthorizationStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        if status == .notDetermined {
            return await withCheckedContinuation { cont in
                ATTrackingManager.requestTrackingAuthorization { newStatus in
                    cont.resume(returning: newStatus)
                }
            }
        } else {
            return status
        }
    }
}
