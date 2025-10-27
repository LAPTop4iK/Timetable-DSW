//
//  PremiumPurchaseButton.swift
//  Timetable DSW
//
//  Reusable purchase button component
//

import SwiftUI
import StoreKit

struct PremiumPurchaseButton: View {
    let productType: ProductType
    let style: ButtonStyleType
    let onSuccess: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.storeKitManager) private var storeKitManager: StoreKitManager?

    enum ButtonStyleType {
        case primary
        case outlined
    }

    var body: some View {
        Button {
            guard let manager = storeKitManager else { return }
            Task {
                let result = await manager.purchase(productType)
                switch result {
                case .success:
                    onSuccess()
                case .cancelled, .pending, .failed:
                    break
                }
            }
        } label: {
            HStack {
                Image(systemName: productType == .premium ? "cart.fill" : "gift.fill")
                if let product = storeKitManager?.products[productType] {
                    Text("\(productType.displayName.localized) • \(product.displayPrice)")
                        .fontWeight(.semibold)
                } else {
                    Text(productType.displayName.localized)
                        .fontWeight(.semibold)
                }
            }
            .font(AppTypography.body.font)
            .foregroundStyle(style == .primary ? AnyShapeStyle(Color.white) : AnyShapeStyle(gradientStyle))
            .padding(EdgeInsets(
                top: AppSpacing.medium.value,
                leading: AppSpacing.xxxl.value,
                bottom: AppSpacing.medium.value,
                trailing: AppSpacing.xxxl.value
            ))
            .frame(maxWidth: .infinity)
            .background {
                if style == .primary {
                    primaryBackground
                } else {
                    outlinedBackground
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var primaryBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(0.9)

            RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.white.color(for: colorScheme).opacity(0.3),
                            AppColor.clear.color(for: colorScheme)
                        ],
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: 100
                    )
                )
        }
        .shadow(
            color: gradientColors[0].opacity(0.4),
            radius: 20,
            x: 0,
            y: 8
        )
    }

    private var outlinedBackground: some View {
        RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
            .strokeBorder(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
    }

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }

    private var gradientStyle: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
