//
//  ValidationError.swift
//  SwiftGenUI
//
//  Errors produced while validating generated schemas.
//

import Foundation

enum ValidationError: LocalizedError, Equatable {
    case unsupportedComponent(String)
    case maxDepthExceeded
    case unregisteredCapability(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedComponent(let type):
            return "Unsupported component: \(type)"
        case .maxDepthExceeded:
            return "Generated UI is too deeply nested"
        case .unregisteredCapability(let name):
            return "Capability is not registered: \(name)"
        }
    }
}
