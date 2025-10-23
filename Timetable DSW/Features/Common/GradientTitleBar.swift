//
//  GradientTitleBar.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 23/10/2025.
//

import SwiftUI

/// Центрированный градиентный заголовок + кнопка "Gotowe" справа
/// со "системной" подложкой под навбар при скролле.
struct GradientTitleBar: View {
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let hPadding: AppSpacing = .large
            let vPadding: AppSpacing = .medium
            let doneHitSlop: CGFloat = 8
            let separatorHeight: CGFloat = 0.5
        }
        static let constants = Constants()
    }

    let title: String
    let onDone: () -> Void
    let showsBackground: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Центрированный градиентный заголовок
            Text(title)
                .font(AppTypography.title2.font)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .overlay(
                    LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .mask(
                    Text(title)
                        .font(AppTypography.title2.font)
                        .fontWeight(.semibold)
                )
                .accessibilityAddTraits(.isHeader)

            // "Gotowe" справа
            HStack {
                Spacer()
                Button(action: onDone) {
                    Text(LocalizedString.generalDone.localized) // "Gotowe"
                        .font(AppTypography.subheadline.font)
                        .fontWeight(.semibold)
                        .overlay(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .mask(
                            Text(LocalizedString.generalDone.localized)
                                .font(AppTypography.subheadline.font)
                                .fontWeight(.semibold)
                        )
                        .contentShape(Rectangle())
                        .padding(.horizontal, Configuration.constants.doneHitSlop)
                        .padding(.vertical, Configuration.constants.doneHitSlop / 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Configuration.constants.hPadding.value)
        .padding(.vertical, Configuration.constants.vPadding.value)
        .background(
            Group {
                if showsBackground {
                    // Системная подложка + нижний сепаратор
                    ZStack(alignment: .bottom) {
                        Rectangle().fill(.ultraThinMaterial)
                        Rectangle()
                            .fill(AppColor.background.color(for: colorScheme).opacity(0.65)) // или AppColor.separator
                            .frame(height: Configuration.constants.separatorHeight)
                    }
                    .transition(.opacity)
                } else {
                    Color.clear
                }
            }
            .ignoresSafeArea(edges: .top)
            .animation(.easeInOut(duration: 0.2), value: showsBackground)
        )
    }
}

