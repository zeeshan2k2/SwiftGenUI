
import Foundation

struct CapabilityExecutor {
    let registry: CapabilityRegistry

    func execute(_ call: CapabilityCall) async throws {
        let capability = registry.capability(named: call.name)
        try await capability?.execute(params: call.params ?? [:])
    }
}
