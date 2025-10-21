//
//  ShadowStyle.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

public struct ShadowStyle {
    // MARK: - Properties
    
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat
    
    // MARK: - Initialization
    
    public init(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 4,
        x: CGFloat = 0,
        y: CGFloat = 4
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}