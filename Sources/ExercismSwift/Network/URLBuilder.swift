import Foundation

public class URLBuilder {
    let base: URL

    init() {
        self.base = Network.exercismBaseURL
    }

    public func url<T>(
        endpoint: ExercismClientPath,
        identifier: EntityIdentifier<T, String>,
        params: [String: String] = [:]
    ) -> URL {
        let newPath = endpoint.rawValue.replacingOccurrences(of: "{identifier}", with: identifier.rawValue)
        guard let url = URL(string: newPath, relativeTo: base) else {
            fatalError("Invalid path, unable to create a URL: \(endpoint)")
        }

        return buildURL(url: url, params: params)
    }

    public func url(
        endpoint: ExercismClientPath,
        params: [String: String] = [:],
        urlArgs: CVarArg...
    ) -> URL {
        let path = String(format: endpoint.rawValue, arguments: urlArgs)
        guard let url = URL(string: path, relativeTo: base) else {
            fatalError("Invalid path, unable to create a URL: \(path)")
        }

        return buildURL(url: url, params: params)
    }

    private func buildURL(url: URL, params: [String: String]) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            fatalError("Invalid url, unable to build components path")
        }

        if !params.isEmpty {
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        guard let result = components.url else {
            fatalError("Unable to create url from components (\(components)")
        }

        return result
    }
}
