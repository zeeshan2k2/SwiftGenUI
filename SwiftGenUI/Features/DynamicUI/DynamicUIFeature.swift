//
//  DynamicUIFeature.swift
//  SwiftGenUI
//
//  TCA feature placeholder for prompt-driven UI generation.
//

import Foundation

struct DynamicUIFeature {
    struct State: Equatable {
        var prompt = ""
        var selectedExample: String?
        var generationStatus = "Ready"

        let examples = [
            "Signup form",
            "Profile card",
            "Task form",
            "Settings screen"
        ]

        let examplePrompts = [
            "Signup form": "Create a signup form with a title, email field, password field, and an orange continue button.",
            "Profile card": "Create a profile card with an avatar placeholder, name, subtitle, and a follow button.",
            "Task form": "Create a task form with title, due date, priority selector, and a bottom save button.",
            "Settings screen": "Create a settings screen with account, notifications, privacy rows, and a sign out button."
        ]
    }
}
