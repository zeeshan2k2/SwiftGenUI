//
//  ScreenSectionGenerationInput.swift
//  SwiftGenUI
//
//  Context required to generate one planned section of a complex screen.
//

import Foundation

struct ScreenSectionGenerationInput: Equatable {
    let userPrompt: String
    let style: ScreenStyleHints
    let rootLayout: ScreenRootLayout
    let section: ScreenSectionPlan

    init(
        userPrompt: String,
        style: ScreenStyleHints,
        rootLayout: ScreenRootLayout,
        section: ScreenSectionPlan
    ) {
        self.userPrompt = userPrompt
        self.style = style
        self.rootLayout = rootLayout
        self.section = section
    }

    init(userPrompt: String, plan: ScreenPlan, section: ScreenSectionPlan) {
        self.init(
            userPrompt: userPrompt,
            style: plan.style,
            rootLayout: plan.rootLayout,
            section: section
        )
    }
}
