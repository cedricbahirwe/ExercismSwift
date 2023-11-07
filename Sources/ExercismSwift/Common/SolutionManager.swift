//
// Created by Kirk Agbenyegah on 26/09/2022.
//

import Foundation

public class SolutionManager {
    let solution: SolutionFile
    let client: NetworkClient
    let fileManager: FileManager

    public init(with solution: SolutionFile, client: NetworkClient) {
        self.solution = solution
        self.client = client
        fileManager = FileManager.default
    }

    private func getOrCreateSolutionDir() throws -> URL? {
        let docsFolder = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)

        let solutionDir = docsFolder.appendingPathComponent("\(solution.exercise.trackId)/\(solution.exercise.id)/", isDirectory: true)

        if !fileManager.fileExists(atPath: solutionDir.relativePath) {
            try fileManager.createDirectory(atPath: solutionDir.path, withIntermediateDirectories: true)
        }

        return solutionDir
    }

    // TODO(kirk - 20/07/22) - Handle exceptions properly

    private func downloadFile(at path: String, to destination: URL, completed: @escaping ((Bool, ExercismClientError?) -> Void)) {
        let url = URL(string: path, relativeTo: URL(string: solution.fileDownloadBaseUrl))!
        client.download(from: url, to: destination, headers: [:]) { result in
            switch result {
            case .success(_):
                completed(true, nil)
            case .failure:
                completed(false, .builderError(message: "Error creating exercise directory"))
            }
        }
    }
    
    
    @available(iOS 13.0.0, *)
    private func downloadFile(at path: String, to destination: URL) async throws -> (Bool, ExercismClientError?) {
        let url = URL(string: path, relativeTo: URL(string: solution.fileDownloadBaseUrl))!
        
        do {
            _ = try await client.download(from: url, to: destination, headers: [:])
            return (true, nil)
        } catch {
            return (false, .builderError(message: "Error creating exercise directory"))
        }
    }

    public func download(_ completed: @escaping (URL?, ExercismClientError?) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.filedownload.queue", attributes: .concurrent)
        var clientError: ExercismClientError?
        var solutionDirectory: URL?

        do {
            if let solutionDir = try getOrCreateSolutionDir() {
                solutionDirectory = solutionDir
                for file in solution.files {
                    group.enter()
                    var fileComponents = file.split(separator: "/")
                    let fileLen = fileComponents.count
                    var destPath = solutionDir
                    let fileName = fileComponents.last!.description

                    if fileLen > 1 {
                        fileComponents.removeLast()
                        destPath = solutionDir.appendingPathComponent(fileComponents.joined(separator: "/"), isDirectory: true)
                        try fileManager.createDirectory(atPath: destPath.path, withIntermediateDirectories: true)
                    }

                    downloadFile(at: file,
                                 to: destPath.appendingPathComponent(fileName)) { complete, error  in
                        if let error = error {
                            clientError = error
                        }

                        if !complete {
                            clientError = .builderError(message: "Error creating exercise directory")
                        }
                    }
                    group.leave()
                }
            }
        } catch let error {
            clientError = .builderError(message: error.localizedDescription)
        }

        group.notify(queue: queue) {
            if let error = clientError {
                completed(nil, error)
            } else {
                completed(solutionDirectory, nil)
            }
        }
    }
    
    @available(iOS 13.0.0, *)
    public func download() async throws -> (URL?, ExercismClientError?) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.filedownload.queue", attributes: .concurrent)
        var clientError: ExercismClientError?
        var solutionDirectory: URL?

        do {
            if let solutionDir = try getOrCreateSolutionDir() {
                solutionDirectory = solutionDir
                for file in solution.files {
                    group.enter()
                    var fileComponents = file.split(separator: "/")
                    let fileLen = fileComponents.count
                    var destPath = solutionDir
                    let fileName = fileComponents.last!.description

                    if fileLen > 1 {
                        fileComponents.removeLast()
                        destPath = solutionDir.appendingPathComponent(fileComponents.joined(separator: "/"), isDirectory: true)
                        try fileManager.createDirectory(atPath: destPath.path, withIntermediateDirectories: true)
                    }
                    
                    let (complete, error) = try await downloadFile(at: file, to: destPath.appendingPathComponent(fileName))
                    
                    if let error = error {
                        clientError = error
                    }

                    if !complete {
                        clientError = .builderError(message: "Error creating exercise directory")
                    }
                    group.leave()
                }
            }
        } catch let error {
            clientError = .builderError(message: error.localizedDescription)
        }

        return await withCheckedContinuation { continuation in
            group.notify(queue: queue) {
                if let error = clientError {
                    continuation.resume(returning: (nil, error))
                } else {
                    continuation.resume(returning: (solutionDirectory, nil))
                }
            }
        }
    }
}
