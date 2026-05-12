//
//  AppCapability.swift
//  SwiftGenUI
//
//  Protocol for trusted native actions.
//

import Foundation

protocol AppCapability {
    var name: String { get }
    func execute(params: [String: String]) async throws
}
