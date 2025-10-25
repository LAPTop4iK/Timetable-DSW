//
//  TimetableWidgetBundle.swift
//  TimetableWidget
//
//  Created by Mikita Laptsionak on 23/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct TimetableWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Main widget with different sizes
        TimetableWidget()
        
        // Live Activity for current class tracking
//        TimetableLiveActivity()
        
        // Control Center widget
//        TimetableControlWidget()
    }
}
