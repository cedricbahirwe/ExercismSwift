import Foundation

public protocol ExercismClientType: AnyObject {
    func tracks(
        completed: @escaping (Result<ListResponse<Track>, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func tracks() async throws -> ListResponse<Track>
    

    func exercises(for track: String,
                   completed: @escaping (Result<ListResponse<Exercise>, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func exercises(for track: String) async throws -> ListResponse<Exercise>

    func validateToken(
        completed: @escaping (Result<ValidateTokenResponse, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func validateToken() async throws -> ValidateTokenResponse

    func solutions(
        for track: String?,
        withStatus status: SolutionStatus?,
        mentoringStatus: MentoringStatus?,
        completed: @escaping (Result<ListResponse<Solution>, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func solutions(
        for track: String?,
        withStatus status: SolutionStatus?,
        mentoringStatus: MentoringStatus?
    ) async throws -> ListResponse<Solution>

    func downloadSolution(
        with id: String,
        for track: String?,
        exercise: String?,
        completed: @escaping (Result<ExerciseDocument, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func downloadSolution(
        with id: String,
        for track: String?,
        exercise: String?
    ) async throws -> ExerciseDocument
}
