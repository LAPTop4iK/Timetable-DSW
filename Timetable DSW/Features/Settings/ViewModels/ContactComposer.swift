import Foundation

struct ContactComposer {
    enum Kind { case bug, feature }

    let appInfoProvider: () -> (version: String, build: String)
    let deviceInfoProvider: () -> (ios: String, model: String)
    let localeProvider: () -> String
    let selectedGroupProvider: () -> String?

    func subject(for kind: Kind) -> String {
        switch kind {
        case .bug:     return LocalizedString.contactEmailSubjectBug.localized
        case .feature: return LocalizedString.contactEmailSubjectFeature.localized
        }
    }

    func body(for kind: Kind, now: Date = Date()) -> String {
        // Заголовки без \n в локализациях (см. Localizable.xcstrings ниже)
        let headerLine: String
        let extraBlock: String

        switch kind {
        case .bug:
            headerLine = LocalizedString.contactEmailBodyBugHeader.localized
            // Список и подзаголовок формируем программно (надёжные переносы):
            extraBlock = [
                "", // пустая строка
                "1)",
                "2)",
                "3)",
                "",
                LocalizedString.contactEmailBodyAdditionalInfo.localized
            ].joined(separator: "\n")

        case .feature:
            headerLine = LocalizedString.contactEmailBodyFeatureHeader.localized
            extraBlock = [
                "", // пустая строка
                LocalizedString.contactEmailBodyDetailsTitle.localized
            ].joined(separator: "\n")
        }

        // Санитайзер: если в каталогах остались строки с «\n», заменим их на реальные переводы.
        let header = headerLine.unescapedNewlines()

        let app = appInfoProvider()
        let dev = deviceInfoProvider()
        let locale = localeProvider()
        let group = selectedGroupProvider() ?? "—"
        let iso = ISO8601DateFormatter().string(from: now)

        let infoLines = [
            "---",
            "\(LocalizedString.contactEmailInfoApp.localized): \(app.version) (\(app.build))",
            "\(LocalizedString.contactEmailInfoiOS.localized): \(dev.ios)",
            "\(LocalizedString.contactEmailInfoDevice.localized): \(dev.model)",
            "\(LocalizedString.contactEmailInfoLocale.localized): \(locale)",
            "\(LocalizedString.contactEmailInfoGroup.localized): \(group)",
            "\(LocalizedString.contactEmailInfoDate.localized): \(iso)"
        ]

        return ([header, extraBlock] + infoLines).joined(separator: "\n")
    }
}

private extension String {
    /// Превращает последовательности `\\n` в реальные переводы строк.
    func unescapedNewlines() -> String {
        replacingOccurrences(of: "\\n", with: "\n")
    }
}
