
import Foundation

struct ScreenPlan: Equatable {
    let purpose: String
    let rootLayout: ScreenRootLayout
    let style: ScreenStyleHints
    let sections: [ScreenSectionPlan]
}

enum ScreenRootLayout: String, Equatable {
    case scrollView
    case vStack
}

struct ScreenStyleHints: Equatable {
    let tone: String
    let backgroundColor: String?
    let accentColor: String?
    let typography: String?
}

struct ScreenSectionPlan: Identifiable, Equatable {
    let id: String
    let title: String
    let purpose: String
    let kind: ScreenSectionKind
}

enum ScreenSectionKind: String, Equatable {
    case header
    case content
    case actions
    case list
    case form
    case footer
}
