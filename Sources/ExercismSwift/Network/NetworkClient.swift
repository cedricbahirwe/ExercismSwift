import Foundation

public enum Network {
    public typealias HTTPHeaders = [String: String]
    
    public static let exercismBaseURL = URL(string: "https://api.exercism.io/")!
    
    public enum HTTPMethod: String {
        case GET, POST, PUT, PATCH, DELETE
    }
    
    public enum Errors: Error {
        case HTTPError(code: Int)
        case genericError(Error)
    }
}

public protocol NetworkClient: AnyObject {
    var headers: Network.HTTPHeaders { get }
    
    func get<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func get<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders?
    ) async throws -> R
    
    func post<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func post<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders?
    ) async throws -> R
    
    func patch<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func patch<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders?
    ) async throws -> R
    
    func delete<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func delete<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders?
    ) async throws -> R
    
    func delete<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func delete<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders?
    ) async throws -> R
    
    
    func download(
        from sourcePath: URL,
        to destPath: URL,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<URL, ExercismClientError>) -> Void
    )
    
    @available(iOS 13.0.0, *)
    func download(
        from sourcePath: URL,
        to destPath: URL,
        headers: Network.HTTPHeaders?
    ) async throws -> URL
}

public class DefaultNetworkClient: NetworkClient {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let defaultHeaders: Network.HTTPHeaders
    private let userAgent = "Exercism macOS"
    
    public init(_ apiToken: String? = nil) {
        
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        var headers = [
            "User-Agent": userAgent,
        ]
        if let apiToken = apiToken {
            headers["Authorization"] = "Bearer \(apiToken)"
        }
        defaultHeaders = headers
    }
    
    public var headers: Network.HTTPHeaders {
        defaultHeaders
    }
    
    public func get<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders? = nil,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    ) {
        
        let request = buildRequest(method: .GET, url: url, headers: headers)
        print(request.url?.absoluteURL ?? "")
        executeRequest(request: request, completed: completed)
    }
    
    
    @available(iOS 13.0.0, *)
    public func get<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders? = nil
    ) async throws -> R {
        let request = buildRequest(method: .GET, url: url, headers: headers)
        print(request.url?.absoluteURL ?? "")
        return try await executeRequest(request: request)
    }
    
    public func post<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders? = nil,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    ) {
        var request = buildRequest(method: .POST, url: url, headers: headers)
        let requestBody: Data
        
        do {
            requestBody = try encoder.encode(body)
        } catch {
            completed(.failure(.bodyEncodingError(error)))
            return
        }
        Environment.log.trace("BODY:\n " + String(data: requestBody, encoding: .utf8)!)
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        executeRequest(request: request, completed: completed)
    }
    
    @available(iOS 13.0.0, *)
    public func post<T: Encodable, R: Decodable>(_ url: URL, body: T, headers: Network.HTTPHeaders?) async throws -> R {
        var request = buildRequest(method: .POST, url: url, headers: headers)
        let requestBody: Data
        
        do {
            requestBody = try encoder.encode(body)
        } catch {
            throw ExercismClientError.bodyEncodingError(error)
        }
        Environment.log.trace("BODY:\n " + String(data: requestBody, encoding: .utf8)!)
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await executeRequest(request: request)
    }
    
    public func patch<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders? = nil,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    ) {
        var request = buildRequest(method: .PATCH, url: url, headers: headers)
        let requestBody: Data
        
        do {
            requestBody = try encoder.encode(body)
        } catch {
            completed(.failure(.bodyEncodingError(error)))
            return
        }
        
        Environment.log.trace("BODY:\n " + String(data: requestBody, encoding: .utf8)!)
        
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        executeRequest(request: request, completed: completed)
    }
    
    @available(iOS 13.0.0, *)
    public func patch<T: Encodable, R: Decodable>(_ url: URL, body: T, headers: Network.HTTPHeaders?) async throws -> R {
        var request = buildRequest(method: .PATCH, url: url, headers: headers)
        let requestBody: Data
        
        do {
            requestBody = try encoder.encode(body)
        } catch {
            throw ExercismClientError.bodyEncodingError(error)
        }
        
        Environment.log.trace("BODY:\n " + String(data: requestBody, encoding: .utf8)!)
        
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await executeRequest(request: request)
    }
    
    public func delete<R: Decodable>(
        _ url: URL,
        headers: Network.HTTPHeaders? = nil,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    ) {
        // swiftlint:disable:next syntactic_sugar
        self.genericDelete(url, body: Optional<Int>.none, headers: headers, completed: completed)
    }
    
    @available(iOS 13.0.0, *)
    public func delete<R: Decodable>(_ url: URL, headers: Network.HTTPHeaders?) async throws -> R {
        try await genericDelete(url, body: Optional<Int>.none, headers: headers)
    }
    
    public func delete<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders? = nil,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    ) {
        self.genericDelete(url, body: body, headers: headers, completed: completed)
    }
    
    @available(iOS 13.0.0, *)
    public func delete<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T,
        headers: Network.HTTPHeaders? = nil
    ) async throws -> R {
        try await genericDelete(url, body: body, headers: headers)
    }
    
    public func download(
        from sourcePath: URL,
        to destPath: URL,
        headers: Network.HTTPHeaders? = [:],
        completed: @escaping (Result<URL, ExercismClientError>) -> Void
    ) {
        let request = initRequest(url: sourcePath, headers: headers)
        
        let task = URLSession.shared.downloadTask(with: request) { url, response, error in
            var completeResult: Result<URL, ExercismClientError>?
            
            if let error = NetworkClientHelpers.extractError(response: response, error: error) {
                completeResult = .failure(error)
            } else if let url = url {
                Environment.log.trace(url.description)
                do {
                    if FileManager.default.fileExists(atPath: destPath.relativePath) {
                        _ = try FileManager.default.replaceItemAt(destPath, withItemAt: url)
                    } else {
                        try FileManager.default.moveItem(at: url, to: destPath)
                    }
                    completeResult = .success(destPath)
                } catch {
                    completeResult = .failure(.genericError(error))
                }
            } else {
                completeResult = .failure(.unsupportedResponseError)
            }
            
            DispatchQueue.main.async {
                guard let completeResult = completeResult else {
                    fatalError("Something is wrong, no result!")
                }
                completed(completeResult)
            }
        }
        task.resume()
    }
    
    @available(iOS 13.0.0, *)
    public func download(
        from sourcePath: URL,
        to destPath: URL,
        headers: Network.HTTPHeaders? = [:]
    ) async throws -> URL {
        let request = initRequest(url: sourcePath, headers: headers)
        
        if #available(iOS 15.0, *) {
            let (url, response) = try await URLSession.shared.download(for: request)
            if let error = NetworkClientHelpers.extractError(data: nil, response: response) {
                throw error
            } else {
                Environment.log.trace(url.description)
                do {
                    if FileManager.default.fileExists(atPath: destPath.relativePath) {
                        _ = try FileManager.default.replaceItemAt(destPath, withItemAt: url)
                    } else {
                        try FileManager.default.moveItem(at: url, to: destPath)
                    }
                    return destPath
                } catch {
                    throw ExercismClientError.genericError(error)
                }
            }
        } else {
            let (data, response) = try await  URLSession.shared.data(from: destPath)
            if let error = NetworkClientHelpers.extractError(data: nil, response: response) {
                throw error
            } else if let url = URL(dataRepresentation: data, relativeTo: nil) {
                Environment.log.trace(url.description)
                do {
                    if FileManager.default.fileExists(atPath: destPath.relativePath) {
                        _ = try FileManager.default.replaceItemAt(destPath, withItemAt: url)
                    } else {
                        try FileManager.default.moveItem(at: url, to: destPath)
                    }
                    return destPath
                } catch {
                    throw ExercismClientError.genericError(error)
                }
            } else {
                throw ExercismClientError.unsupportedResponseError
            }
        }
    }
    
    private func genericDelete<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T?,
        headers: Network.HTTPHeaders?,
        completed: @escaping (Result<R, ExercismClientError>) -> Void
    ) {
        var request = buildRequest(method: .DELETE, url: url, headers: headers)
        if let body = body {
            let requestBody: Data
            
            do {
                requestBody = try encoder.encode(body)
            } catch {
                completed(.failure(.bodyEncodingError(error)))
                return
            }
            
            Environment.log.trace("BODY:\n " + String(data: requestBody, encoding: .utf8)!)
            
            request.httpBody = requestBody
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        executeRequest(request: request, completed: completed)
    }
    
    @available(iOS 13.0.0, *)
    private func genericDelete<T: Encodable, R: Decodable>(
        _ url: URL,
        body: T?,
        headers: Network.HTTPHeaders?
    ) async throws -> R {
        var request = buildRequest(method: .DELETE, url: url, headers: headers)
        if let body = body {
            let requestBody: Data
            
            do {
                requestBody = try encoder.encode(body)
            } catch {
                throw ExercismClientError.bodyEncodingError(error)
            }
            
            Environment.log.trace("BODY:\n " + String(data: requestBody, encoding: .utf8)!)
            
            request.httpBody = requestBody
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await executeRequest(request: request)
    }
    
    private func initRequest(url: URL, headers: Network.HTTPHeaders? = [:]) -> URLRequest {
        let allHeaders = defaultHeaders.merging(headers ?? [:]) { (_, new) in
            new
        }
        var request = URLRequest(url: url)
        for item in allHeaders {
            request.setValue(item.value, forHTTPHeaderField: item.key)
        }
        
        return request
    }
    
    private func buildRequest(
        method: Network.HTTPMethod,
        url: URL,
        headers: Network.HTTPHeaders?
    ) -> URLRequest {
        var request = initRequest(url: url, headers: headers)
        request.httpMethod = method.rawValue
        
        return request
    }
    
    private func executeRequest<T: Decodable>(
        request: URLRequest,
        completed: @escaping (Result<T, ExercismClientError>) -> Void
    ) {
        Environment.log.debug("Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var completeResult: Result<T, ExercismClientError>?
            
            if let error = NetworkClientHelpers.extractError(data: data, response: response, error: error) {
                completeResult = .failure(error)
            } else if let data = data {
                Environment.log.trace(String(data: data, encoding: .utf8) ?? "")
                do {
                    Environment.log.trace(String(data: data, encoding: .utf8) ?? "")
                    let result = try self.decoder.decode(T.self, from: data)
                    completeResult = .success(result)
                } catch let decodingError as Swift.DecodingError {
                    completeResult = .failure(.decodingError(decodingError))
                } catch {
                    completeResult = .failure(.genericError(error))
                }
            } else {
                completeResult = .failure(.unsupportedResponseError)
            }
            
            DispatchQueue.main.async {
                guard let completeResult = completeResult else {
                    fatalError("Something is wrong, no result!")
                }
                completed(completeResult)
            }
        }
        task.resume()
    }
    
    @available(iOS 13.0.0, *)
    private func executeRequest<T: Decodable>(request: URLRequest) async throws -> T {
        
        Environment.log.debug("Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for : request)
        if let error = NetworkClientHelpers.extractError(data: data, response: response) {
            throw error
        } else {
            Environment.log.trace(String(data: data, encoding: .utf8) ?? "")
            do {
                let result = try self.decoder.decode(T.self, from: data)
                return result
            } catch let decodingError as Swift.DecodingError {
                throw ExercismClientError.decodingError(decodingError)
            } catch {
                throw ExercismClientError.genericError(error)
            }
        }
        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            var completeResult: Result<T, ExercismClientError>?
//            
//            if let error = NetworkClientHelpers.extractError(data: data, response: response, error: error) {
//                completeResult = .failure(error)
//            } else if let data = data {
//                Environment.log.trace(String(data: data, encoding: .utf8) ?? "")
//                do {
//                    Environment.log.trace(String(data: data, encoding: .utf8) ?? "")
//                    let result = try self.decoder.decode(T.self, from: data)
//                    completeResult = .success(result)
//                } catch let decodingError as Swift.DecodingError {
//                    completeResult = .failure(.decodingError(decodingError))
//                } catch {
//                    completeResult = .failure(.genericError(error))
//                }
//            } else {
//                completeResult = .failure(.unsupportedResponseError)
//            }
//            
//            DispatchQueue.main.async {
//                guard let completeResult = completeResult else {
//                    fatalError("Something is wrong, no result!")
//                }
//                completed(completeResult)
//            }
//        }
//        task.resume()
    }
}
