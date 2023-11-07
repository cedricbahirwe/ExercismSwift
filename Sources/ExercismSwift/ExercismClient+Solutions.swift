import Foundation

// MARK: - Solutions

extension ExercismClient {
    public func solutions(
        for track: String? = nil,
        withStatus status: SolutionStatus? = nil,
        mentoringStatus: MentoringStatus? = nil,
        completed: @escaping (Result<ListResponse<Solution>, ExercismClientError>) -> Void
    ) {
        var params: [String: String] = [:]
        if let t = track {
            params["track_slug"] = t
        }

        if let s = status {
            params["status"] = s.rawValue
        }

        if let mt = mentoringStatus {
            params["mentoring_status"] = mt.rawValue
        }

        networkClient.get(
            urlBuilder.url(path: .solutions,
                params: params),
            headers: headers(),
            completed: completed
        )
    }
    
    @available(iOS 13.0.0, *)
    public func solutions(for track: String?, withStatus status: SolutionStatus?, mentoringStatus: MentoringStatus?) async throws -> ListResponse<Solution> {
        var params: [String: String] = [:]
        if let t = track {
            params["track_slug"] = t
        }

        if let s = status {
            params["status"] = s.rawValue
        }

        if let mt = mentoringStatus {
            params["mentoring_status"] = mt.rawValue
        }

        return try await networkClient.get(
            urlBuilder.url(path: .solutions,
                params: params),
            headers: headers()
        )
    }

    public func downloadSolution(
        with id: String = "latest",
        for track: String? = nil,
        exercise: String? = nil,
        completed: @escaping (Result<ExerciseDocument, ExercismClientError>) -> Void
    ) {
        var params: [String: String] = [:]

        if let t = track {
            params["track_id"] = t
        }

        if let e = exercise {
            params["exercise_id"] = e
        }

        networkClient.get(
            urlBuilder.url(path: .solutionsFile, params: params, urlArgs: id),
            headers: headers()
        ) { (result: Result<SolutionFile, ExercismClientError>) in
            switch result {
            case .success(let solution):
                let solutionManager = SolutionManager(with: solution, client: self.networkClient)
                solutionManager.download { url, error in
                    if let url = url {
                        completed(.success(ExerciseDocument(exerciseDirectory: url, solution: solution)))
                    }  else {
                        completed(.failure(.builderError(message: "Error creating exercise directory")))
                    }
                }

            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    
    @available(iOS 13.0.0, *)
    public func downloadSolution(
        with id: String = "latest",
        for track: String? = nil,
        exercise: String? = nil
    ) async throws -> ExerciseDocument {
        var params: [String: String] = [:]
        
        if let t = track {
            params["track_id"] = t
        }
        
        if let e = exercise {
            params["exercise_id"] = e
        }
        
        do {
            let solution: SolutionFile = try await networkClient.get(urlBuilder.url(path: .solutionsFile,
                                                                                    params: params,
                                                                                    urlArgs: id),
                                                                     headers: headers())
            let solutionManager = SolutionManager(with: solution, client: networkClient)
            let (url, _) = try await solutionManager.download()
            if let url = url {
                return ExerciseDocument(exerciseDirectory: url, solution: solution)
            }  else {
                throw ExercismClientError.builderError(message: "Error creating exercise directory")
            }
        }
    }
    
}
