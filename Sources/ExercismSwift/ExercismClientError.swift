import Foundation

public enum ExercismClientError: Error {
    case genericError(Error)
    case apiError(status: Int, code: String, message: String)
    case bodyEncodingError(Error)
    case decodingError(Error)
    case unsupportedResponseError
    case builderError(message: String)
}

public enum ExercismErrorCode: String {
    case invalidJson = "invalid_json"
    case invalidRequestURL = "invalid_request_url"
    case invalidRequest = "invalid_request"
    case validationError = "validation_error"
    case unauthorized = "unauthorized"
}
