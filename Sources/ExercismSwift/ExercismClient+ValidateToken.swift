import Foundation

// MARK: - Tracks

extension ExercismClient {
    public func validateToken(
        completed: @escaping (Result<ValidateTokenResponse, ExercismClientError>) -> Void
    ) {
        networkClient.get(
            urlBuilder.url(path: .validateToken),
            headers: headers(),
            completed: completed
        )
    }
    
    @available(iOS 13.0.0, *)
    public func validateToken() async throws -> ValidateTokenResponse {
        try await networkClient.get(
            urlBuilder.url(path: .validateToken),
            headers: headers()
        )
    }
}
