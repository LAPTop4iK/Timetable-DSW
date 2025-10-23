//
//  EventCard.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import SwiftUI

// MARK: - Lightweight props for Equatable comparison

struct EventCardProps: Equatable, Identifiable {
    let id: String
    let title: String
    let type: String?
    let start: Date?
    let end: Date?
    let room: String
    let grading: String?
    let remarks: String?
    let studyTrack: String?
    let groups: String?
    let teacherId: Int?
    let teacherName: String?

    static func from(_ e: ScheduleEvent) -> EventCardProps {
        .init(
            id: e.id,
            title: e.title,
            type: e.type,
            start: e.startDate,
            end: e.endDate,
            room: e.displayRoom,
            grading: e.grading,
            remarks: e.remarks,
            studyTrack: e.studyTrack,
            groups: e.groups,
            teacherId: e.teacherId,
            teacherName: e.teacherName
        )
    }
}

// MARK: - Event Style Configuration

struct EventStyle {
    let accentColor: Color
    let gradientColors: [Color]
    let isOnline: Bool
    let isCancelled: Bool
    let eventKind: EventType

    private let eventTypeDetector: EventTypeDetector

    init(
        from event: ScheduleEvent,
        colorScheme: ColorScheme,
        eventTypeDetector: EventTypeDetector = DefaultEventTypeDetector()
    ) {
        self.eventTypeDetector = eventTypeDetector

        let kind = eventTypeDetector.detectEventType(from: event.type)
        self.eventKind = kind
        self.accentColor = Self.accentColor(for: kind)
        self.gradientColors = Self.gradientColors(for: kind, colorScheme: colorScheme)
        self.isOnline = eventTypeDetector.isOnline(remarks: event.remarks)
        self.isCancelled = eventTypeDetector.isCancelled(remarks: event.remarks)
    }

    private static func accentColor(for type: EventType) -> Color {
        switch type {
        case .lecture: return .orange
        case .exercise: return .blue
        case .laboratory: return .purple
        case .other: return .orange
        }
    }

    private static func gradientColors(for type: EventType, colorScheme: ColorScheme) -> [Color] {
        let style: GradientStyle
        switch type {
        case .lecture: style = .lecture
        case .exercise: style = .exercise
        case .laboratory: style = .laboratory
        case .other: style = .lecture
        }
        return style.colors(for: colorScheme)
    }
}

// MARK: - Event Card

struct EventCard: View {
    // MARK: - Configuration

    struct Configuration: ComponentConfiguration {
        struct Constants {
            let cornerRadius: AppCornerRadius = .large
            let verticalLineWidth: CGFloat = AppDimensions.lineMedium.value
            let containerPadding: AppSpacing = .large
            let verticalLineSpacing: AppSpacing = .medium
            let contentSpacing: AppSpacing = .medium
            let timeLineWidth: CGFloat = AppDimensions.lineSmall.value
            let timeLineHeight: CGFloat = AppDimensions.buttonHeight.value
            let avatarSize: CGFloat = AppDimensions.avatarMedium.value
            let onlineIndicatorSize: CGFloat = AppDimensions.dotLarge.value
            let shadowRadius: CGFloat = 8
            let shadowY: CGFloat = 2
            let shadowOpacity: Double = 0.2
            let blurOpacity: Double = 0.7
            let darkFillOpacity: Double = 0.08
            let lightFillOpacity: Double = 0.16

            let pastOverlayLightOpacity: Double = 0.08
            let pastOverlayDarkOpacity: Double = 0.14
            let pastSaturation: Double = 0.80
            let pastOpacity: Double = 0.80

            let cancelledOverlayLightOpacity: Double = 0.22
            let cancelledOverlayDarkOpacity: Double = 0.28
        }

        static let constants = Constants()
    }

    // MARK: - Properties

    let event: ScheduleEvent
    let showTeacherName: Bool
    let onTeacherTap: (() -> Void)?
    let onCardTap: (() -> Void)?
    let now: Date

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Dependencies

    private let dateService: DateService

    // MARK: - Computed Properties

    private var style: EventStyle {
        EventStyle(from: event, colorScheme: colorScheme)
    }

    private var isPast: Bool {
        guard let end = event.endDate else { return false }
        return end < now
    }

    private var props: EventCardProps {
        EventCardProps.from(event)
    }

    // MARK: - Initialization

    init(
        event: ScheduleEvent,
        showTeacherName: Bool,
        onTeacherTap: (() -> Void)? = nil,
        onCardTap: (() -> Void)? = nil,
        now: Date = Date(),
        dateService: DateService = DefaultDateService.shared
    ) {
        self.event = event
        self.showTeacherName = showTeacherName
        self.onTeacherTap = onTeacherTap
        self.onCardTap = onCardTap
        self.now = now
        self.dateService = dateService
    }

    // MARK: - Body

    var body: some View {
        RoundedShadowContainer(
            corners: .allCorners,
            cornerRadius: Configuration.constants.cornerRadius.value,
            fill: cardFillColor,
            blurMaterial: .ultraThinMaterial,
            blurOpacity: Configuration.constants.blurOpacity,
            shadow: .init(
                color: style.gradientColors[0].opacity(Configuration.constants.shadowOpacity),
                radius: Configuration.constants.shadowRadius,
                x: 0,
                y: Configuration.constants.shadowY
            ),
            contentInsets: .init(
                top: Configuration.constants.containerPadding.value,
                leading: Configuration.constants.containerPadding.value,
                bottom: Configuration.constants.containerPadding.value,
                trailing: Configuration.constants.containerPadding.value
            )
        ) {
            HStack(alignment: .top, spacing: Configuration.constants.verticalLineSpacing.value) {
                AccentLine(gradientColors: style.gradientColors)

                VStack(alignment: .leading, spacing: Configuration.constants.contentSpacing.value) {
                    MainInfoRow(
                        event: event,
                        style: style,
                        startTime: startTime,
                        endTime: endTime,
                        roomAndGrading: roomAndGrading,
                        showLargeOnlineBadge: style.isOnline,
                        showCancelledBadge: style.isCancelled
                    )

                    if hasMiddleSection {
                        PersonOrGroupSection(
                            showTeacherName: showTeacherName,
                            teacherName: event.teacherName,
                            groups: event.groups,
                            gradientColors: style.gradientColors,
                            onTeacherTap: onTeacherTap
                        )
                    }

                    if hasBottomSection {
                        AdditionalInfoSection(
                            studyTrack: event.studyTrack,
                            remarks: event.remarks
                        )
                    }
                }
            }
        }
        .modifier(StatusDimModifier(isPast: isPast, isCancelled: style.isCancelled))
        .onTapGesture { onCardTap?() }
        .equatable(by: props) // не перестраивать без изменения входных пропсов
    }

    // MARK: - Computed Properties

    private var cardFillColor: Color {
        let opacity = colorScheme == .dark ? Configuration.constants.darkFillOpacity : Configuration.constants.lightFillOpacity
        return style.gradientColors[0].opacity(opacity)
    }

    private var hasMiddleSection: Bool {
        (showTeacherName && event.teacherName != nil) ||
        (!showTeacherName && event.groups != nil)
    }

    private var hasBottomSection: Bool {
        event.studyTrack != nil || (event.remarks != nil && event.remarks != "Brak")
    }

    private var startTime: String {
        guard let start = event.startDate else { return "" }
        return dateService.formatTime(start)
    }

    private var endTime: String {
        guard let end = event.endDate else { return "" }
        return dateService.formatTime(end)
    }

    private var roomAndGrading: String {
        var result = event.displayRoom
        let separator = result.isEmpty ? "" : ", "
        if let grading = event.grading {
            result += "\(separator)\(grading)"
        }
        return result
    }
}

// MARK: - Status Dim Modifier (past & cancelled)

private struct StatusDimModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let isPast: Bool
    let isCancelled: Bool

    func body(content: Content) -> some View {
        content
            .saturation((isPast || isCancelled) ? EventCard.Configuration.constants.pastSaturation : 1.0)
            .opacity((isPast || isCancelled) ? EventCard.Configuration.constants.pastOpacity : 1.0)
            .overlay(
                Group {
                     if isCancelled {
                        RoundedRectangle(cornerRadius: EventCard.Configuration.constants.cornerRadius.value)
                            .fill(
                                LinearGradient(
                                    colors: GradientStyle.cancelled
                                        .colors(for: colorScheme)
                                        .map { $0.opacity(colorScheme == .dark
                                                          ? EventCard.Configuration.constants.cancelledOverlayDarkOpacity
                                                          : EventCard.Configuration.constants.cancelledOverlayLightOpacity) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .allowsHitTesting(false)
                    } else if isPast {
                        RoundedRectangle(cornerRadius: EventCard.Configuration.constants.cornerRadius.value)
                            .fill(
                                Color.black.opacity(
                                    colorScheme == .dark
                                    ? EventCard.Configuration.constants.pastOverlayDarkOpacity
                                    : EventCard.Configuration.constants.pastOverlayLightOpacity
                                )
                            )
                            .allowsHitTesting(false)
                    }
                }
            )
    }
}

// MARK: - Accent Line

private struct AccentLine: View {
    let gradientColors: [Color]

    var body: some View {
        RoundedRectangle(cornerRadius: EventCard.Configuration.constants.verticalLineWidth / 2)
            .fill(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: EventCard.Configuration.constants.verticalLineWidth)
            .frame(maxHeight: .infinity)
    }
}

// MARK: - Main Info Row

private struct MainInfoRow: View {
    let event: ScheduleEvent
    let style: EventStyle
    let startTime: String
    let endTime: String
    let roomAndGrading: String
    let showLargeOnlineBadge: Bool
    let showCancelledBadge: Bool

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium.value) {
            LeftSideInfo(
                title: event.title,
                roomAndGrading: roomAndGrading
            )

            Spacer(minLength: AppSpacing.medium.value)

            RightSideInfo(
                type: event.type,
                startTime: startTime,
                endTime: endTime,
                gradientColors: style.gradientColors,
                showLargeOnlineBadge: showLargeOnlineBadge,
                showCancelledBadge: showCancelledBadge
            )
        }
    }
}

// MARK: - Left Side Info

private struct LeftSideInfo: View {
    struct Constants {
        let titleSize: CGFloat = 18
        let roomSize: CGFloat = 14
        let spacing: AppSpacing = .xs
        let rowSpacing: AppSpacing = .small
    }
    private let constants = Constants()

    let title: String
    let roomAndGrading: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: constants.spacing.value) {
            Text(title)
                .font(AppTypography.custom(size: constants.titleSize, weight: .semibold).font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: constants.rowSpacing.value) {
                Text(roomAndGrading)
                    .font(AppTypography.custom(size: constants.roomSize, weight: .regular).font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Online Indicator

private struct OnlineIndicator: View {
    struct Constants {
        let circleSize: CGFloat = 5
        let fontSize: CGFloat = 11
        let horizontalPadding: AppSpacing = .xs
        let verticalPadding: AppSpacing = .xxs
        let backgroundOpacity: Double = 0.15
    }
    private let constants = Constants()

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: AppSpacing.xxs.value) {
            Circle()
                .fill(AppColor.success.color(for: colorScheme))
                .frame(width: constants.circleSize, height: constants.circleSize)

            Text(LocalizedString.generalOnline.localized)
                .font(AppTypography.custom(size: constants.fontSize, weight: .medium).font)
                .foregroundAppColor(.success, colorScheme: colorScheme)
        }
        .padding(.horizontal, constants.horizontalPadding.value)
        .padding(.vertical, constants.verticalPadding.value)
        .background(
            Capsule()
                .fill(AppColor.success.color(for: colorScheme).opacity(constants.backgroundOpacity))
        )
    }
}

// MARK: - Right Side Info

private struct RightSideInfo: View {
    struct Constants {
        let typeSize: CGFloat = 16
        let spacing: AppSpacing = .xs
        let badgeSpacing: AppSpacing = .xs
    }
    private let constants = Constants()

    let type: String?
    let startTime: String
    let endTime: String
    let gradientColors: [Color]
    let showLargeOnlineBadge: Bool
    let showCancelledBadge: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: constants.spacing.value) {
            if type != nil || showLargeOnlineBadge || showCancelledBadge {
                HStack(spacing: constants.badgeSpacing.value) {
                    if showCancelledBadge {
                        LargeBage(
                            style: .cancelled,
                            text: LocalizedString.generalCancelled.localized
                        )
                    } else if showLargeOnlineBadge {
                        LargeBage()
                    }
                    if let type = type {
                        Text(type)
                            .font(AppTypography.custom(size: constants.typeSize, weight: .semibold).font)
                            .foregroundStyle(
                                LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                            )
                            .lineLimit(1)
                    }
                }
            }

            TimeBlock(
                startTime: startTime,
                endTime: endTime,
                gradientColors: gradientColors
            )
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Time Block

private struct TimeBlock: View {
    struct Constants {
        let timeSize: CGFloat = 16
        let spacing: AppSpacing = .small
        let verticalSpacing: AppSpacing = .xs
    }
    private let constants = Constants()

    let startTime: String
    let endTime: String
    let gradientColors: [Color]

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: constants.spacing.value) {
            VStack(alignment: .trailing, spacing: constants.verticalSpacing.value) {
                Text(startTime)
                    .font(AppTypography.custom(size: constants.timeSize, weight: .medium).font)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                Text(endTime)
                    .font(AppTypography.custom(size: constants.timeSize, weight: .medium).font)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)
            }

            RoundedRectangle(cornerRadius: EventCard.Configuration.constants.timeLineWidth / 2)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(
                    width: EventCard.Configuration.constants.timeLineWidth,
                    height: EventCard.Configuration.constants.timeLineHeight
                )
        }
    }
}

// MARK: - Person Or Group Section

private struct PersonOrGroupSection: View {
    let showTeacherName: Bool
    let teacherName: String?
    let groups: String?
    let gradientColors: [Color]
    let onTeacherTap: (() -> Void)?

    var body: some View {
        if showTeacherName, let teacherName = teacherName {
            TeacherView(
                name: teacherName,
                gradientColors: gradientColors,
                onTap: onTeacherTap
            )
        } else if !showTeacherName, let groups = groups {
            GroupView(groups: groups, gradientColors: gradientColors)
        }
    }
}

// MARK: - Teacher View

private struct TeacherView: View {
    struct Constants {
        let spacing: AppSpacing = .medium
        let titleSize: CGFloat = 12
        let nameSize: CGFloat = 14
        let initialsSize: CGFloat = 14
        let nameSpacing: CGFloat = 1
        let backgroundOpacity: Double = 0.15
        let iconSpacing: AppSpacing = .xs
    }
    private let constants = Constants()

    let name: String
    let gradientColors: [Color]
    let onTap: (() -> Void)?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if let _ = onTap {
                content(isInteractive: true)
            } else {
                content(isInteractive: false)
            }
        }
    }

    private func content(isInteractive: Bool) -> some View {
        HStack(spacing: constants.spacing.value) {
            if isInteractive, let onTap {
                Button(action: onTap) {
                    avatarView
                    nameContent(isInteractive: isInteractive)
                }
            } else {
                avatarView
                nameContent(isInteractive: isInteractive)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(constants.backgroundOpacity) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: EventCard.Configuration.constants.avatarSize,
                    height: EventCard.Configuration.constants.avatarSize
                )

            Text(initials)
                .font(AppTypography.custom(size: constants.initialsSize, weight: .semibold).font)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private func nameContent(isInteractive: Bool) -> some View {
        VStack(alignment: .leading, spacing: constants.nameSpacing) {
            if let title = parsedName.title {
                HStack(spacing: constants.iconSpacing.value) {
                    Text(title)
                        .font(AppTypography.custom(size: constants.titleSize, weight: .medium).font)
                        .foregroundColor(
                            isInteractive
                                ? gradientColors[0].opacity(0.7)
                                : AppColor.secondaryText.color(for: colorScheme)
                        )

                    Text(parsedName.firstName)
                        .font(AppTypography.custom(size: constants.nameSize, weight: .medium).font)
                        .foregroundStyle(nameGradient(isInteractive: isInteractive))
                }
            } else {
                Text(parsedName.firstName)
                    .font(AppTypography.custom(size: constants.nameSize, weight: .medium).font)
                    .foregroundStyle(nameGradient(isInteractive: isInteractive))
            }

            if let lastName = parsedName.lastName {
                Text(lastName)
                    .font(AppTypography.custom(size: constants.nameSize, weight: .medium).font)
                    .foregroundStyle(nameGradient(isInteractive: isInteractive))
            }
        }
    }

    private func nameGradient(isInteractive: Bool) -> LinearGradient {
        LinearGradient(
            colors: isInteractive ? gradientColors : [AppColor.primaryText.color(for: colorScheme)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var parsedName: (title: String?, firstName: String, lastName: String?) {
        let components = name.split(separator: " ").map(String.init)
        let titles = ["mgr", "dr", "prof", "inż", "hab"]

        var titleParts: [String] = []
        var nameParts: [String] = []

        for component in components {
            let lowercased = component.lowercased().replacingOccurrences(of: ".", with: "")
            if titles.contains(lowercased) {
                titleParts.append(component)
            } else {
                nameParts.append(component)
            }
        }

        let title = titleParts.isEmpty ? nil : titleParts.joined(separator: " ")
        let firstName = nameParts.first ?? name
        let lastName = nameParts.count > 1 ? nameParts[1] : nil

        return (title, firstName, lastName)
    }

    private var initials: String {
        let name = parsedName
        if let lastName = name.lastName {
            let firstInitial = name.firstName.prefix(1)
            let lastInitial = lastName.prefix(1)
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else {
            return String(name.firstName.prefix(1)).uppercased()
        }
    }
}

// MARK: - Group View

private struct GroupView: View {
    struct Constants {
        let iconSize: CGFloat = 14
        let textSize: CGFloat = 14
        let spacing: AppSpacing = .medium
    }
    private let constants = Constants()

    let groups: String
    let gradientColors: [Color]

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: constants.spacing.value) {
            AppIcon.person3Fill.image()
                .font(AppTypography.custom(size: constants.iconSize, weight: .regular).font)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(groups)
                .font(AppTypography.custom(size: constants.textSize, weight: .regular).font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
        }
    }
}

// MARK: - Additional Info Section

private struct AdditionalInfoSection: View {
    struct Constants {
        let textSize: CGFloat = 12
        let spacing: AppSpacing = .xxs
    }
    private let constants = Constants()

    let studyTrack: String?
    let remarks: String?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: constants.spacing.value) {
            if let track = studyTrack {
                Text(track)
                    .font(AppTypography.custom(size: constants.textSize, weight: .regular).font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .lineLimit(2)
            }

            if let remarks = remarks, remarks != "Brak" {
                Text(remarks)
                    .font(AppTypography.custom(size: constants.textSize, weight: .regular).font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .italic()
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Reusable Large Badge (online / cancelled)

private struct LargeBage: View {
    struct Constants {
        let fontSize: CGFloat = 12
        let hPad: AppSpacing = .small
        let vPad: AppSpacing = .xxs
        let strokeWidth: CGFloat = AppDimensions.lineSmall.value
        let glowOpacity: Double = 0.28
        let glowRadius: CGFloat = 10
    }
    private let c = Constants()

    var style: GradientStyle = .online
    var text: String? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(style.linearGradient(for: colorScheme))

            Capsule(style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.28), .clear],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 22
                    )
                )

            Text((text ?? LocalizedString.generalOnline.localized).uppercased())
                .font(AppTypography.custom(size: c.fontSize, weight: .semibold).font)
                .foregroundColor(.white)
                .padding(.horizontal, c.hPad.value)
                .padding(.vertical, c.vPad.value)
        }
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: c.strokeWidth)
        )
        .shadow(
            color: style.colors(for: colorScheme).first?.opacity(c.glowOpacity) ?? .clear,
            radius: c.glowRadius, x: 0, y: 1
        )
        .fixedSize()
    }
}

// MARK: - Equatable helper

extension View {
    /// Оборачивает в EquatableView, сравнивая по предоставленному значению.
    func equatable<T: Equatable>(by value: T) -> some View {
        EquatableWrapper(content: self, value: value)
    }
}

private struct EquatableWrapper<Content: View, Value: Equatable>: View, Equatable {
    let content: Content
    let value: Value

    static func == (l: Self, r: Self) -> Bool { l.value == r.value }
    var body: some View { content }
}
