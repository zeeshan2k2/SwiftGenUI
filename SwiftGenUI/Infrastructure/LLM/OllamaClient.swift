
import Foundation

struct OllamaClient {
    private let repository: LLMRepository

    init(repository: LLMRepository = OllamaLLMRepository()) {
        self.repository = repository
    }

    func generateSchema(from prompt: String) async throws -> UIComponent {
        try await repository.generateSchema(from: prompt)
    }

    func generateScreenPlan(from prompt: String) async throws -> ScreenPlan {
        try await repository.generateScreenPlan(from: prompt)
    }

    func generateScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        try await repository.generateScreenSection(from: input)
    }

    func retryScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        try await repository.retryScreenSection(from: input)
    }
}
