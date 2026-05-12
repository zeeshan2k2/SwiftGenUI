//
//  DynamicRenderer.swift
//  SwiftGenUI
//
//  SwiftUI renderer for validated UI schemas.
//

import SwiftUI

struct DynamicRenderer: View {
    let component: UIComponent

    var body: some View {
        Text(component.props?.text ?? component.type.rawValue)
    }
}
