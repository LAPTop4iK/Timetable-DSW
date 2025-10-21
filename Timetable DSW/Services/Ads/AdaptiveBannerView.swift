//
//  AdaptiveBannerView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import SwiftUI
import GoogleMobileAds

struct AdaptiveBannerView: View {
    @Environment(\.adCoordinator) private var coordinator
    @State private var bannerHeight: CGFloat = 50

    var body: some View {
        if coordinator?.isAdDisabled() ?? true {
            EmptyView()
        } else {
            GeometryReader { geometry in
                BannerViewRepresentable(
                    coordinator: coordinator,
                    availableWidth: geometry.size.width,
                    onHeightChange: { newHeight in
                        bannerHeight = newHeight
                    }
                )
            }
            .frame(height: bannerHeight)
        }
    }
}

private struct BannerViewRepresentable: UIViewRepresentable {
    let coordinator: AdCoordinator?
    let availableWidth: CGFloat
    let onHeightChange: (CGFloat) -> Void

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        return container
    }

    func updateUIView(_ container: UIView, context: Context) {
        let currentWidth = container.subviews.first?.frame.width ?? 0
        let widthDifference = abs(currentWidth - availableWidth)

        // Обновляем только при значительном изменении
        guard widthDifference > 10 || container.subviews.isEmpty else {
            return
        }

        container.subviews.forEach { $0.removeFromSuperview() }

        guard let coordinator = coordinator, availableWidth > 0 else { return }

        let bannerView = coordinator.makeBannerView(width: availableWidth)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            bannerView.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor)
        ])

        // Получаем точную высоту
        DispatchQueue.main.async {
            let adSize = currentOrientationAnchoredAdaptiveBanner(width: availableWidth)
            let height = adSize.size.height
            if height > 0 {
                onHeightChange(height)
            }
        }
    }
}

// MARK: - Styled Components

struct CompactBannerAd: View {
    var body: some View {
        AdaptiveBannerView()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
