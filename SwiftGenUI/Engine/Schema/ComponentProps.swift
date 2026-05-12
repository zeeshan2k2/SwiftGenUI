//
//  ComponentProps.swift
//  SwiftGenUI
//
//  Serializable component properties controlled by AI output.
//

import Foundation

struct ComponentProps: Codable, Equatable {
    var text: String?
    var placeholder: String?
    var spacing: Double?
    var padding: Double?
    var foregroundColor: String?
    var backgroundColor: String?
    var cornerRadius: Double?
}
