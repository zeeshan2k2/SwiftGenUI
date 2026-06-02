
import Foundation

struct CompactComponentDTO: Decodable {
    let id: String
    let t: String
    let p: CompactPropsDTO?
    let c: [CompactComponentDTO]?

    func toUIComponent() throws -> UIComponent {
        UIComponent(
            id: id,
            type: try t.toComponentType(),
            props: p?.toComponentProps(),
            children: try c?.map { try $0.toUIComponent() },
            capability: nil
        )
    }
}

struct CompactPropsDTO: Decodable {
    let txt: String?
    let ph: String?
    let sp: Double?
    let pad: Double?
    let fg: String?
    let bg: String?
    let cr: Double?
    let fs: Double?
    let fw: String?
    let ta: String?
    let ll: Int?
    let r: String?
    let al: String?
    let w: Double?
    let h: Double?
    let maxW: Double?
    let minH: Double?
    let shadow: String?
    let bd: String?
    let bw: Double?
    let op: Double?

    func toComponentProps() -> ComponentProps {
        ComponentProps(
            text: txt,
            placeholder: ph,
            spacing: sp,
            padding: pad,
            foregroundColor: fg,
            backgroundColor: bg,
            cornerRadius: cr,
            fontSize: fs,
            fontWeight: fw,
            textAlignment: ta,
            lineLimit: ll,
            textRole: r,
            alignment: al,
            width: w,
            height: h,
            maxWidth: maxW,
            minHeight: minH,
            shadow: shadow,
            borderColor: bd,
            borderWidth: bw,
            opacity: op
        )
    }
}

private extension String {
    func toComponentType() throws -> ComponentType {
        switch self {
        case "vS":
            return .vStack
        case "hS":
            return .hStack
        case "zS":
            return .zStack
        case "txt":
            return .text
        case "btn":
            return .button
        case "tf":
            return .textField
        case "spacer":
            return .spacer
        case "div":
            return .divider
        case "card":
            return .card
        case "scr":
            return .scrollView
        case "sec":
            return .section
        default:
            throw LLMError.invalidJSON
        }
    }
}
