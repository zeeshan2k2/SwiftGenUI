//
//  SwiftDataHistoryRepository.swift
//  SwiftGenUI
//
//  SwiftData-backed storage for generated UI history.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataHistoryRepository {
    static let shared = SwiftDataHistoryRepository()

    private let container: ModelContainer
    private let context: ModelContext

    private init() {
        do {
            container = try ModelContainer(for: HistoryRecord.self)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to create SwiftData history container: \(error)")
        }
    }

    func loadHistory() throws -> [PersistedHistoryItem] {
        var descriptor = FetchDescriptor<HistoryRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 50

        return try context.fetch(descriptor).map { record in
            PersistedHistoryItem(
                id: record.id,
                prompt: record.prompt,
                schema: record.schema,
                warning: record.warning,
                generationDuration: record.generationDuration,
                createdAt: record.createdAt
            )
        }
    }

    func saveHistoryItem(_ item: PersistedHistoryItem) throws {
        try deleteHistoryItem(id: item.id)

        let record = HistoryRecord(
            id: item.id,
            prompt: item.prompt,
            schema: item.schema,
            warning: item.warning,
            generationDuration: item.generationDuration,
            createdAt: item.createdAt
        )
        context.insert(record)
        try context.save()
    }

    func deleteHistoryItem(id: String) throws {
        let descriptor = FetchDescriptor<HistoryRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )

        for record in try context.fetch(descriptor) {
            context.delete(record)
        }

        try context.save()
    }
}
