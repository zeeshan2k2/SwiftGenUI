
import Foundation

struct CapabilityCall: Codable, Equatable {
    let name: String
    let params: [String: String]?
}
