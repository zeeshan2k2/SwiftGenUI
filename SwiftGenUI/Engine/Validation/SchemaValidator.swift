//
//  SchemaValidator.swift
//  SwiftGenUI
//
//  Validates AI-generated schemas before rendering.
//

import Foundation

struct SchemaValidator {
    private let maxDepth: Int

    init(maxDepth: Int = 5) {
        self.maxDepth = maxDepth
    }

    func validate(_ component: UIComponent) throws {
        try validate(component, depth: 1)
    }

    private func validate(_ component: UIComponent, depth: Int) throws {
        guard depth <= maxDepth else {
            throw ValidationError.maxDepthExceeded
        }

        if let capability = component.capability {
            throw ValidationError.unregisteredCapability(capability.name)
        }

        if let children = component.children, !children.isEmpty {
            guard component.type.canContainChildren else {
                throw ValidationError.unsupportedComponent("\(component.type.rawValue) cannot contain children")
            }

            for child in children {
                try validate(child, depth: depth + 1)
            }
        }
    }
}

private extension ComponentType {
    var canContainChildren: Bool {
        switch self {
        case .vStack, .hStack, .zStack:
            return true
        case .text, .button, .textField, .spacer, .divider:
            return false
        }
    }
}
