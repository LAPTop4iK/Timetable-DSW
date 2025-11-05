//
//  UIDevice+type.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 05/11/2025.
//

import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
