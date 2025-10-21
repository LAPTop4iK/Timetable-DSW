import SwiftUI

// MARK: - SubjectDetailView

struct SubjectDetailView: View {
    // MARK: Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            // Layout
            let spacing: AppSpacing = .large
            let sectionSpacing: AppSpacing = .medium
            let padding: AppSpacing = .large

            // Header stack spacing (title + assessment)
            let headerTightSpacing: CGFloat = 6

            // Stats container
            let statsCorner: AppCornerRadius = .large
            let statItemCorner: AppCornerRadius = .medium
            let statItemPadding: AppSpacing = .large
            let statColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            let containerStrokeOpacity: Double = 0.30

            // Тени (компактные, цветные, без смещений)
            let containerShadowOpacityColored: Double = 0.35
            let containerShadowRadiusTight: CGFloat = 7

            let pillStrokeOpacity: Double = 0.28
            let pillShadowOpacityColored: Double = 0.35
            let pillShadowRadiusTight: CGFloat = 6

            // Date line paddings
            let dateChipVPad: CGFloat = 8
            let dateChipHPad: CGFloat = 12

            // Typography
            let pillNumberFont = AppTypography.custom(size: 22, weight: .semibold).font
            let pillLabelFont  = AppTypography.caption2.font
        }
        static let constants = Constants()
    }

    // MARK: Environment & State
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: SubjectDetailViewModel

    // MARK: Init
    init(subject: Subject) {
        _viewModel = StateObject(wrappedValue: SubjectDetailViewModel(subject: subject))
    }

    // MARK: Derived
    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }
    private var accentShadowColor: Color {
        gradientColors.dropFirst().first ?? gradientColors.first ?? Color.accentColor
    }

    /// Чистая заливка для пилюль: светлая в Light, деликатная в Dark
    private var cleanPillFill: LinearGradient {
        let isDark = colorScheme == .dark
        return LinearGradient(
            colors: isDark
                ? [Color.white.opacity(0.10), Color.white.opacity(0.04)] // чистый «white-glass» в тёмной теме
                : [Color.white.opacity(0.96), Color.white.opacity(0.88)], // почти белая в светлой
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Configuration.constants.spacing.value) {
                    VStack(alignment: .leading, spacing: Configuration.constants.headerTightSpacing) {
                        subjectHeader
                        assessmentLine
                    }

                    statsSection
                    sectionsList
                }
                .padding(.horizontal, Configuration.constants.padding.value)
                .padding(.bottom, Configuration.constants.padding.value)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { doneButton }
            }
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 96) }
            #if DEBUG
            .measurePerformance(name: "SubjectDetailView", category: .viewAppear)
            #endif
        }
    }

    // MARK: - Header

    private var subjectHeader: some View {
        Text(viewModel.subject.name)
            .font(AppTypography.title2.font)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .themedForeground(.primary, colorScheme: colorScheme)
            .accessibilityLabel(viewModel.subject.name)
    }

    // MARK: - Assessment

    private var assessmentLine: some View {
        Group {
            if let grading = mostCommonGrading, !grading.isEmpty {
                Text("\(LocalizedString.subjectsGradingType.localized): \(grading)")
                    .font(AppTypography.subheadline.font)
                    .fontWeight(.semibold)
                    .themedForeground(.primary, colorScheme: colorScheme)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("\(LocalizedString.subjectsGradingType.localized): \(grading)")
            }
        }
    }

    private var mostCommonGrading: String? {
        let values = viewModel.subject.schedule
            .compactMap { $0.grading?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !values.isEmpty else { return nil }
        let freq = Dictionary(grouping: values, by: { $0 }).mapValues(\.count)
        return freq.max(by: { $0.value < $1.value })?.key
    }

    // MARK: - Navbar

    private var doneButton: some View {
        Button(LocalizedString.generalDone.localized) { dismiss() }
            .fontWeight(.medium)
            .themedForeground(.header, colorScheme: colorScheme)
    }

    // MARK: - Stats (outline + compact colored shadow)

    private var statsSection: some View {
        let s = viewModel.stats

        return VStack(spacing: Configuration.constants.sectionSpacing.value) {
            LazyVGrid(columns: Configuration.constants.statColumns,
                      spacing: Configuration.constants.sectionSpacing.value) {
                statPill(title: LocalizedString.subjectsTotal.localized,        value: s.total)
                statPill(title: LocalizedString.subjectsPast.localized,         value: s.past)
                statPill(title: LocalizedString.subjectsUpcoming.localized,     value: s.upcoming)
                statPill(title: LocalizedString.subjectsLectures.localized,     value: s.lectures)
                statPill(title: LocalizedString.subjectsExercises.localized,    value: s.exercises)
                statPill(title: LocalizedString.subjectsLaboratories.localized, value: s.laboratories)
            }
        }
        .padding(Configuration.constants.statItemPadding.value)
        .background(
            RoundedRectangle(cornerRadius: Configuration.constants.statsCorner.value)
                .strokeBorder(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(Configuration.constants.containerStrokeOpacity) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .shadow(
                    color: accentShadowColor.opacity(Configuration.constants.containerShadowOpacityColored),
                    radius: Configuration.constants.containerShadowRadiusTight,
                    x: 0, y: 0
                )
        )
    }

    private func statPill(title: String, value: Int) -> some View {
        ZStack {
            // Лёгкое свечение — оставляем
            RoundedRectangle(cornerRadius: Configuration.constants.statItemCorner.value)
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(0.10) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 10)

            // ЧИСТАЯ заливка (вместо .ultraThinMaterial)
            RoundedRectangle(cornerRadius: Configuration.constants.statItemCorner.value)
                .fill(cleanPillFill)
                .overlay(
                    RoundedRectangle(cornerRadius: Configuration.constants.statItemCorner.value)
                        .strokeBorder(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(Configuration.constants.pillStrokeOpacity) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: accentShadowColor.opacity(Configuration.constants.pillShadowOpacityColored),
                    radius: Configuration.constants.pillShadowRadiusTight,
                    x: 0, y: 0
                )
        }
        .overlay(
            VStack(spacing: 6) {
                Text("\(value)")
                    .font(Configuration.constants.pillNumberFont)
                    .themedForeground(.primary, colorScheme: colorScheme)
                Text(title)
                    .font(Configuration.constants.pillLabelFont)
                    .fontWeight(.medium)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
        )
        .frame(maxWidth: .infinity, minHeight: 64)
    }

    // MARK: - Sections

    private var sectionsList: some View {
        VStack(spacing: Configuration.constants.sectionSpacing.value) {
            ForEach(viewModel.sections, id: \.date) { section in
                VStack(alignment: .leading, spacing: 8) {
                    dateLine(for: section.date)
                    VStack(spacing: Configuration.constants.sectionSpacing.value) {
                        ForEach(section.items) { ev in
                            EventCard(
                                event: ev,
                                showTeacherName: true,
                                onTeacherTap: nil,
                                now: Date()
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Date Line

    private func dateLine(for date: Date) -> some View {
        HStack(spacing: 8) {
            Text(Self.dotDateFormatter.string(from: date))
                .font(AppTypography.subheadline.font)
                .fontWeight(.semibold)
                .themedForeground(.primary, colorScheme: colorScheme)

            Text(Self.weekdayShortFormatter.string(from: date))
                .font(AppTypography.subheadline.font)
                .fontWeight(.semibold)
                .themedForeground(.primary, colorScheme: colorScheme)
        }
        .padding(.vertical, Configuration.constants.dateChipVPad)
        .padding(.horizontal, Configuration.constants.dateChipHPad)
    }
}

// MARK: - Formatters

private extension SubjectDetailView {
    static let dotDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()

    static let weekdayShortFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("EEE")
        return df
    }()
}
