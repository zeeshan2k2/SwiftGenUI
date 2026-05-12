//
//  CapabilityRegistry.swift
//  SwiftGenUI
//
//  Stores native actions that generated UI is allowed to request.
//

import Foundation

final class CapabilityRegistry {
    private var capabilities: [String: AppCapability] = [:]

    func register(_ capability: AppCapability) {
        capabilities[capability.name] = capability
    }

    func capability(named name: String) -> AppCapability? {
        capabilities[name]
    }
}
