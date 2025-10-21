//
//  AdLoadingView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import SwiftUI

struct AdLoadingView: View {
    let adType: AdType
    let coordinator: AdCoordinator?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading ad...")
            } else if let error = error {
                VStack(spacing: 8) {
                    Text("Failed to load ad")
                        .font(.caption)
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await loadAd() }
                    }
                    .font(.caption)
                }
            } else {
                EmptyView()
            }
        }
        .task {
            await loadAd()
        }
    }
    
    private func loadAd() async {
        guard let coordinator = coordinator else { return }
        isLoading = true
        error = nil
        
        do {
            try await coordinator.loadAd(type: adType)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
