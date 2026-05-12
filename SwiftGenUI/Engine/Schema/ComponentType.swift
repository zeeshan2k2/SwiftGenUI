//
//  ComponentType.swift
//  SwiftGenUI
//
//  Supported native component kinds.
//

import Foundation

enum ComponentType: String, Codable, Equatable {
    case vStack
    case hStack
    case zStack
    case text
    case button
    case textField
    case spacer
    case divider
}
