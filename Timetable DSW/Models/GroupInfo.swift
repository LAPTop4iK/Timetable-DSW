//
//  GroupInfo.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

struct GroupInfo: Identifiable, Codable, Hashable, Sendable {
    let groupId: Int
    let code: String
    let name: String
    let tracks: [TrackInfo]
    let program: String
    let faculty: String

    var id: Int { groupId }

    var displayName: String {
        "\(code) - \(name)"
    }
}