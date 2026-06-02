
import Foundation
import SwiftData

@Model
final class HistoryRecord {
    @Attribute(.unique) var id: String
    var prompt: String
    var schema: String
    var warning: String?
    var generationDuration: Double?
    var createdAt: Date

    init(
        id: String,
        prompt: String,
        schema: String,
        warning: String?,
        generationDuration: Double?,
        createdAt: Date
    ) {
        self.id = id
        self.prompt = prompt
        self.schema = schema
        self.warning = warning
        self.generationDuration = generationDuration
        self.createdAt = createdAt
    }
}
