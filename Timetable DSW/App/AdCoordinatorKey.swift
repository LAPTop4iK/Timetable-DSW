//
//  AdCoordinatorKey.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import SwiftUI

private struct AdCoordinatorKey: EnvironmentKey {
    static let defaultValue: AdCoordinator? = nil
}

extension EnvironmentValues {
    var adCoordinator: AdCoordinator? {
        get { self[AdCoordinatorKey.self] }
        set { self[AdCoordinatorKey.self] = newValue }
    }
}

extension View {
    func adCoordinator(_ coordinator: AdCoordinator) -> some View {
        environment(\.adCoordinator, coordinator)
    }
}
