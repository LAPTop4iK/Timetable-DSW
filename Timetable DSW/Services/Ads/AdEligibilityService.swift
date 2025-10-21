//
//  AdEligibilityService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


protocol AdEligibilityService {
    var canShowAds: Bool { get }
    func checkEligibility() throws
}