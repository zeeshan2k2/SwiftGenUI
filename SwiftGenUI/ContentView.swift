//
//  ContentView.swift
//  SwiftGenUI
//
//  Created by Zeeshan Waheed on 13/05/2026.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store = Store(initialState: DynamicUIFeature.State()) {
        DynamicUIFeature()
    }

    var body: some View {
        DynamicUIView(store: store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
