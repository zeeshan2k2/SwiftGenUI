//
//  CapabilityCall.swift
//  SwiftGenUI
//
//  Schema reference to a pre-registered native action.
//

import Foundation

struct CapabilityCall: Codable, Equatable {
    let name: String
    let params: [String: String]?
}
