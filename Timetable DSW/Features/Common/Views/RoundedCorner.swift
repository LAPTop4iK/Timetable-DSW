//
//  RoundedCorner.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct RoundedCorner: Shape {
    // MARK: - Properties
    
    var radius: CGFloat
    var corners: UIRectCorner
    
    // MARK: - Shape
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}