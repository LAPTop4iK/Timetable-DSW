//
//  AdProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import UIKit.UIViewController
import Combine

protocol AdProvider {
    associatedtype AdObject

    var adType: AdType { get }
    var isReady: Bool { get }

    func load() async throws
    func reset()
}

protocol PresentableAdProvider: AdProvider {
    func present(from viewController: UIViewController) async throws
}

protocol RewardableAdProvider: PresentableAdProvider {
    var rewardPublisher: AnyPublisher<Bool, Never> { get }
}

protocol ViewAdProvider: AdProvider {
    associatedtype ViewType
    func createView() -> ViewType
}
