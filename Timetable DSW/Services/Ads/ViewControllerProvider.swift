//
//  ViewControllerProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import UIKit.UIViewController

protocol ViewControllerProvider {
    func getRootViewController() async -> UIViewController?
    func getTopMostViewController() async -> UIViewController?
    func acquirePresentingViewController(timeout: TimeInterval) async throws -> UIViewController
}
