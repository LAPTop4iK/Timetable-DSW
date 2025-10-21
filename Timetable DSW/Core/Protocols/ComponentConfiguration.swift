//
//  ComponentConfiguration.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

// MARK: - Component Configuration Protocol

protocol ComponentConfiguration {
    associatedtype Constants
    static var constants: Constants { get }
}