//
//  TabBarItem.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

struct TabBarItem: Identifiable {
    let id = UUID()
    let icon: AppIcon
    let title: LocalizedString
    let tag: Int
    let accessibilityIdentifier: String
}
