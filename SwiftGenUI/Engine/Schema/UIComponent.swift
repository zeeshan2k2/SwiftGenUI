
import Foundation

struct UIComponent: Codable, Identifiable, Equatable {
    let id: String
    let type: ComponentType
    let props: ComponentProps?
    let children: [UIComponent]?
    let capability: CapabilityCall?
}
