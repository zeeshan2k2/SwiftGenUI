//
//  HistoryClient.swift
//  SwiftGenUI
//
//  TCA dependency for generated UI history persistence.
//

import ComposableArchitecture
import Foundation

struct PersistedHistoryItem: Equatable, Sendable {
    let id: String
    let prompt: String
    let schema: String
    let warning: String?
    let generationDuration: TimeInterval?
    let createdAt: Date
}

struct HistoryClient {
    var loadHistory: @Sendable () async throws -> [PersistedHistoryItem]
    var saveHistoryItem: @Sendable (PersistedHistoryItem) async throws -> Void
    var deleteHistoryItem: @Sendable (String) async throws -> Void
}

extension HistoryClient: DependencyKey {
    static let liveValue = HistoryClient(
        loadHistory: {
            try await MainActor.run {
                try SwiftDataHistoryRepository.shared.loadHistory()
            }
        },
        saveHistoryItem: { item in
            try await MainActor.run {
                try SwiftDataHistoryRepository.shared.saveHistoryItem(item)
            }
        },
        deleteHistoryItem: { id in
            try await MainActor.run {
                try SwiftDataHistoryRepository.shared.deleteHistoryItem(id: id)
            }
        }
    )

    static let previewValue = HistoryClient.noop
    static let testValue = HistoryClient.noop

    private static let noop = HistoryClient(
        loadHistory: { [] },
        saveHistoryItem: { _ in },
        deleteHistoryItem: { _ in }
    )
}

extension DependencyValues {
    var historyClient: HistoryClient {
        get { self[HistoryClient.self] }
        set { self[HistoryClient.self] = newValue }
    }
}
