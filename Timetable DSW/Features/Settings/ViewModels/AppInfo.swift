//
//  AppInfo.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


import Foundation
import UIKit

enum AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    static var versionString: String { "\(version) (\(build))" }
}

enum DeviceInfo {
    static var iOSVersion: String { UIDevice.current.systemVersion }

    static var deviceIdentifier: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let mirror = Mirror(reflecting: sysinfo.machine)
        return mirror.children.reduce(into: "") { acc, element in
            guard let v = element.value as? Int8, v != 0 else { return }
            acc.append(String(UnicodeScalar(UInt8(v))))
        }
    }
}
