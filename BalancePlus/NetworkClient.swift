import Foundation

struct APIConfig {
    static let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!
}

protocol RequestBody: Encodable {}
protocol ResponseBody: Decodable {}

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case serializationError(Error)
    case httpError(statusCode: Int)
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес сервера. Пожалуйста, попробуйте позже."
        case .noData:
            return "Сервер не вернул данные. Пожалуйста, попробуйте позже."
        case .serializationError:
            return "Ошибка обработки данных. Пожалуйста, обновите приложение или обратитесь в поддержку."
        case .httpError(let statusCode):
            if (400..<500).contains(statusCode) {
                return "Ошибка запроса. Пожалуйста, проверьте введенные данные."
            } else if (500..<600).contains(statusCode) {
                return "Ошибка сервера. Пожалуйста, попробуйте позже."
            } else {
                return "Неизвестная ошибка: \(statusCode). Пожалуйста, свяжитесь с поддержкой."
            }
        case .unauthorized:
            return "Ошибка авторизации. Пожалуйста, войдите снова."
        case .forbidden:
            return "У вас нет доступа к этому ресурсу."
        case .notFound:
            return "Запрашиваемый ресурс не найден."
        case .serverError:
            return "Ошибка сервера. Пожалуйста, попробуйте позже."
        case .unknownError(let underlyingError):
            return "Произошла неизвестная ошибка. (\(underlyingError.localizedDescription)). Пожалуйста, свяжитесь с поддержкой."
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound):
            return true
        case (.serializationError(let e1), .serializationError(let e2)):
            return e1.localizedDescription == e2.localizedDescription
        case (.httpError(let s1), .httpError(let s2)),
             (.serverError(let s1), .serverError(let s2)):
            return s1 == s2
        case (.unknownError(let e1), .unknownError(let e2)):
            return e1.localizedDescription == e2.localizedDescription
        default:
            return false
        }
    }
}

protocol RequestConfiguration {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: RequestBody? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class NetworkClient {
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private var authToken: String?

    init(session: URLSession = .shared,
         jsonDecoder: JSONDecoder = JSONDecoder(),
         jsonEncoder: JSONEncoder = JSONEncoder(),
         token: String
    ) {
        self.session = session
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder

        self.jsonDecoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        self.jsonEncoder.dateEncodingStrategy = .iso8601withFractionalSeconds
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        self.authToken = token
    }

    func request<Res: ResponseBody>(
        config: RequestConfiguration,
        responseType: Res.Type
    ) async throws -> Res {
        guard var urlComponents = URLComponents(url: config.baseURL.appendingPathComponent(config.path),
                                                resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        if let queryParams = config.queryParameters, !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = config.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        config.headers?.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = config.body {
            do {
                request.httpBody = try await Task.detached(priority: .background) {
                    try self.jsonEncoder.encode(body)
                }.value
            } catch {
                throw NetworkError.serializationError(error)
            }
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 400..<500:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            if Res.self == EmptyResponse.self {
                return EmptyResponse() as! Res
            }
            throw NetworkError.noData
        }

        do {
            return try await Task.detached(priority: .background) {
                try self.jsonDecoder.decode(responseType, from: data)
            }.value
        } catch {
            throw NetworkError.serializationError(error)
        }
    }
}

struct EmptyResponse: ResponseBody {}
extension Array: ResponseBody where Element: ResponseBody {}
