import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed(Error)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL. Check Settings."
        case .badResponse(let code) where code == 401:
            return "Unauthorized — check your auth token."
        case .badResponse(let code):
            return "Server returned \(code)."
        case .decodingFailed:
            return "Couldn't decode server response."
        case .unauthorized:
            return "Auth token missing or invalid."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
