//
//  AdPreloader.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import SwiftUI

struct AdPreloader: ViewModifier {
    let types: [AdType]
    let coordinator: AdCoordinator?

    func body(content: Content) -> some View {
        content
            .task {
                guard let coordinator = coordinator, !coordinator.isAdDisabled() else { return }

                for type in types {
                    try? await coordinator.loadAd(type: type)
                }
            }
    }
}

extension View {
    func preloadAds(_ types: AdType..., coordinator: AdCoordinator?) -> some View {
        modifier(AdPreloader(types: types, coordinator: coordinator))
    }
}
