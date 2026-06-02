
import Foundation

protocol LLMRepository {
    func generateSchema(from prompt: String) async throws -> UIComponent
    func generateScreenPlan(from prompt: String) async throws -> ScreenPlan
    func generateScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent
    func retryScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent
}
