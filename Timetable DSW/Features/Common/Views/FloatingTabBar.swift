//
//  FloatingTabBar.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

// MARK: - Tab Bar Configuration

struct TabBarConfiguration {
    // MARK: - Configuration
    
    struct Constants {
        let gradientStyle: GradientStyle
        let showLabels: Bool
        let iconSize: CGFloat
        let backgroundBlur: Material
        let cornerRadius: AppCornerRadius
        let height: CGFloat
        let horizontalPadding: AppSpacing
        let bottomPadding: AppSpacing
        let showTopBorder: Bool
        let topBorderHeight: CGFloat
        let buttonWidth: CGFloat
        let buttonHeight: CGFloat
        let buttonSpacing: AppSpacing
        let backgroundOpacity: Double
        let scalePressed: Double
        let scaleSelected: Double
        let springResponse: Double
        let springDamping: Double
        let shadowRadius: CGFloat
        let shadowY: CGFloat
        let shadowOpacity: Double
        let rotationDuration: Double
        let blurRadius: CGFloat
        let glowOpacity: Double
        let glowStartRadius: CGFloat
        let glowEndRadius: CGFloat
    }
    
    static func adaptive(colorScheme: ColorScheme) -> Constants {
        Constants(
            gradientStyle: .primary,
            showLabels: false,
            iconSize: AppDimensions.iconLarge.value + 2,
            backgroundBlur: .ultraThinMaterial,
            cornerRadius: .xxl,
            height: AppDimensions.tabBarHeight.value,
            horizontalPadding: .xl,
            bottomPadding: .small, // xxl? cconfig
            showTopBorder: false,
            topBorderHeight: AppDimensions.lineSmall.value,
            buttonWidth: 60,
            buttonHeight: 60,
            buttonSpacing: .xs,
            backgroundOpacity: 0.2,
            scalePressed: 0.95,
            scaleSelected: 1.1,
            springResponse: 0.3,
            springDamping: 0.6,
            shadowRadius: 12,
            shadowY: -2,
            shadowOpacity: 0.1,
            rotationDuration: 3,
            blurRadius: 8,
            glowOpacity: 0.3,
            glowStartRadius: 5,
            glowEndRadius: 30
        )
    }
}

// MARK: - Gradient Blur Background

struct GradientBlurBackground: View {
    // MARK: - Properties
    
    let style: GradientStyle
    
    // MARK: - State
    
    @State private var rotationAngle: Double = 0
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    
    private struct Constants {
        static let rotationDuration: Double = 3
        static let blurRadius: CGFloat = 8
        static let glowOpacity: Double = 0.3
        static let glowStartRadius: CGFloat = 5
        static let glowEndRadius: CGFloat = 30
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
            
            LinearGradient(
                colors: style.colors(for: colorScheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(Circle())
            .blur(radius: Constants.blurRadius)
            .rotationEffect(.degrees(rotationAngle))
            .onAppear {
                withAnimation(
                    .linear(duration: Constants.rotationDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    rotationAngle = 360
                }
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.white.color(for: colorScheme).opacity(Constants.glowOpacity),
                            AppColor.clear.color(for: colorScheme)
                        ],
                        center: .center,
                        startRadius: Constants.glowStartRadius,
                        endRadius: Constants.glowEndRadius
                    )
                )
        }
    }
}

// MARK: - Tab Bar Background

struct TabBarBackground: View {
    // MARK: - Properties
    
    let configuration: TabBarConfiguration.Constants
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: configuration.cornerRadius.value)
                .fill(configuration.backgroundBlur)
            
            RoundedRectangle(cornerRadius: configuration.cornerRadius.value)
                .fill(AppColor.background.color(for: colorScheme).opacity(configuration.backgroundOpacity))
            
            if configuration.showTopBorder {
                topBorder
            }
        }
        .shadow(
            color: AppColor.black.color(for: colorScheme).opacity(configuration.shadowOpacity),
            radius: configuration.shadowRadius,
            x: 0,
            y: configuration.shadowY
        )
    }
    
    private var topBorder: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    configuration.gradientStyle.linearGradient(
                        for: colorScheme,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: configuration.topBorderHeight)
            
            Spacer()
        }
        .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius.value))
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    // MARK: - Properties
    
    let tab: TabBarItem
    let isSelected: Bool
    let configuration: TabBarConfiguration.Constants
    let namespace: Namespace.ID
    let action: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let hapticService: HapticFeedbackService
    
    // MARK: - Initialization
    
    init(
        tab: TabBarItem,
        isSelected: Bool,
        configuration: TabBarConfiguration.Constants,
        namespace: Namespace.ID,
        action: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.tab = tab
        self.isSelected = isSelected
        self.configuration = configuration
        self.namespace = namespace
        self.action = action
        self.hapticService = hapticService
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: handleTap) {
            VStack(spacing: configuration.buttonSpacing.value) {
                iconView
                
                if configuration.showLabels {
                    labelView
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var iconView: some View {
        ZStack {
            if isSelected {
                GradientBlurBackground(style: configuration.gradientStyle)
                    .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                    .frame(width: configuration.buttonWidth, height: configuration.buttonHeight)
            }
            
            tab.icon.image()
                .font(.system(size: configuration.iconSize, weight: .medium))
                .foregroundAppColor(isSelected ? .white : .secondaryText, colorScheme: colorScheme)
                .scaleEffect(isSelected ? configuration.scaleSelected : 1.0)
        }
        .frame(width: configuration.buttonWidth, height: configuration.buttonHeight)
    }
    
    private var labelView: some View {
        Text(tab.title.localized)
            .font(AppTypography.caption2.font)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundAppColor(isSelected ? .primaryText : .secondaryText, colorScheme: colorScheme)
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        hapticService.impact(style: .light)
        action()
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    // MARK: - Properties

    let tabs: [TabBarItem]
    @Binding var selectedTab: Int

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bottomInsetService: DefaultBottomInsetService
    @Environment(\.adCoordinator) private var adCoordinator

    // MARK: - Namespace

    @Namespace private var animation

    // MARK: - Computed Properties

    private var configuration: TabBarConfiguration.Constants {
        TabBarConfiguration.adaptive(colorScheme: colorScheme)
    }

    private var dynamicBottomPadding: CGFloat {
        bottomInsetService.tabBarBottomPadding
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            tabBar
            bannerAd
        }
    }

    private var bannerAd: some View {
        VStack(spacing: 0) {
            if adCoordinator?.isAdDisabled() == false {
                AdaptiveBannerView()
                    .background(AppColor.background.color(for: colorScheme))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.tag,
                    configuration: configuration,
                    namespace: animation,
                    action: {
                        withAnimation(.spring(response: configuration.springResponse, dampingFraction: configuration.springDamping)) {
                            selectedTab = tab.tag
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: configuration.height)
        .background {
            TabBarBackground(configuration: configuration)
        }
        .padding(.horizontal, configuration.horizontalPadding.value)
    }
}
