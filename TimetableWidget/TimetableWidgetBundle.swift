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
        TimetableWidget()
        TimetableWidgetControl()
        TimetableWidgetLiveActivity()
    }
}
