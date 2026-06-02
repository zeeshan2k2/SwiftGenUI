
import Foundation

struct GeminiGenerateContentRequestDTO: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig

    struct Content: Encodable {
        let role: String
        let parts: [Part]
    }

    struct Part: Encodable {
        let text: String
    }

    struct GenerationConfig: Encodable {
        let temperature: Double
        let maxOutputTokens: Int
        let responseMimeType: String

        enum CodingKeys: String, CodingKey {
            case temperature
            case maxOutputTokens
            case responseMimeType
        }
    }
}

struct GeminiGenerateContentResponseDTO: Decodable {
    let candidates: [Candidate]?

    struct Candidate: Decodable {
        let content: Content?
    }

    struct Content: Decodable {
        let parts: [Part]?
    }

    struct Part: Decodable {
        let text: String?
    }
}
