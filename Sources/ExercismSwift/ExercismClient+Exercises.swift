import Foundation

// MARK: - Tracks

extension ExercismClient {
    public func exercises(
        for track: String,
        completed: @escaping (Result<ListResponse<Exercise>, ExercismClientError>) -> Void
    ) {
        networkClient.get(
            urlBuilder.url(path: .exercises,
                           urlArgs: track),
            headers: headers(),
            completed: completed
        )
    }
    
    @available(iOS 13.0.0, *)
    public func exercises(for track: String) async throws -> ListResponse<Exercise> {
        try await networkClient.get(
            urlBuilder.url(path: .exercises,
                           urlArgs: track),
            headers: headers()
        )
    }
}
