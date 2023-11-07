import Foundation

// MARK: - Tracks

extension ExercismClient {
    public func tracks(
        completed: @escaping (Result<ListResponse<Track>, ExercismClientError>) -> Void
    ) {
        networkClient.get(
            urlBuilder.url(path: .tracks),
            headers: headers(),
            completed: completed
        )
    }
    
    @available(iOS 13.0.0, *)
    public func tracks() async throws -> ListResponse<Track> {
        try await networkClient.get(urlBuilder.url(path: .tracks), headers: headers())
    }
}
