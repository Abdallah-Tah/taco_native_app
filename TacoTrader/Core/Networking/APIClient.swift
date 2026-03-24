import Foundation

final class APIClient: ObservableObject {
    static let shared = APIClient()

    private var baseURL: String { AppSettings.shared.backendURL }
    private var token: String { AppSettings.shared.authToken }

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func fetch<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.badResponse(statusCode: 0)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.badResponse(statusCode: http.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}
