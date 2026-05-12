//
//  UIComponent.swift
//  SwiftGenUI
//
//  Recursive schema node for generated native UI.
//

import Foundation

struct UIComponent: Codable, Identifiable, Equatable {
    let id: String
    let type: ComponentType
    let props: ComponentProps?
    let children: [UIComponent]?
    let capability: CapabilityCall?
}
