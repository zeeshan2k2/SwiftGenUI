
import Foundation

struct ScreenPlanDTO: Decodable {
    let purpose: String
    let root: String
    let style: ScreenStyleHintsDTO
    let sections: [ScreenSectionPlanDTO]

    func toScreenPlan() throws -> ScreenPlan {
        ScreenPlan(
            purpose: purpose,
            rootLayout: try root.toScreenRootLayout(),
            style: style.toScreenStyleHints(),
            sections: try sections.map { try $0.toScreenSectionPlan() }
        )
    }
}

struct ScreenStyleHintsDTO: Decodable {
    let tone: String
    let bg: String?
    let accent: String?
    let type: String?

    func toScreenStyleHints() -> ScreenStyleHints {
        ScreenStyleHints(
            tone: tone,
            backgroundColor: bg,
            accentColor: accent,
            typography: type
        )
    }
}

struct ScreenSectionPlanDTO: Decodable {
    let id: String
    let title: String
    let purpose: String
    let kind: String

    func toScreenSectionPlan() throws -> ScreenSectionPlan {
        ScreenSectionPlan(
            id: id,
            title: title,
            purpose: purpose,
            kind: try kind.toScreenSectionKind()
        )
    }
}

private extension String {
    func toScreenRootLayout() throws -> ScreenRootLayout {
        switch self {
        case "scr":
            return .scrollView
        case "vS":
            return .vStack
        default:
            throw LLMError.invalidJSON
        }
    }

    func toScreenSectionKind() throws -> ScreenSectionKind {
        guard let kind = ScreenSectionKind(rawValue: self) else {
            throw LLMError.invalidJSON
        }

        return kind
    }
}
