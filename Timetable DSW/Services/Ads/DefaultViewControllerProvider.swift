//
//  DefaultViewControllerProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import UIKit

@MainActor
final class DefaultViewControllerProvider: ViewControllerProvider {
    func getRootViewController() async -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }
    
    func getTopMostViewController() async -> UIViewController? {
        guard let root = await getRootViewController() else { return nil }
        
        var top = root
        while true {
            if let presented = top.presentedViewController, !presented.isBeingDismissed {
                top = presented
            } else if let nav = top as? UINavigationController, let visible = nav.visibleViewController {
                top = visible
            } else if let tab = top as? UITabBarController, let selected = tab.selectedViewController {
                top = selected
            } else if let split = top as? UISplitViewController, let last = split.viewControllers.last {
                top = last
            } else {
                break
            }
        }
        return top
    }
    
    func acquirePresentingViewController(timeout: TimeInterval = 2.0) async throws -> UIViewController {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if let vc = await getTopMostViewController(),
               vc.presentedViewController == nil,
               !vc.isBeingPresented,
               !vc.isBeingDismissed,
               vc.view.window != nil {
                return vc
            }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        throw AdError.timeout
    }
}
