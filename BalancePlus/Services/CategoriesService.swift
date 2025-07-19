import Foundation

protocol CategoriesServiceProtocol {
    func fetchAllCategories() async throws -> [Category]
    func fetchCategoriesByDirection(for direction: Direction) async throws -> [Category]
}

struct GetCategoriesConfig: RequestConfiguration {
    let baseURL: URL = APIConfig.baseURL
    let path: String = "/categories"
    let method: HTTPMethod = .get
    var headers: [String: String]? = nil
    var queryParameters: [String: String]? = nil
    var body: RequestBody? = nil
}

final class CategoriesService: CategoriesServiceProtocol {
    private let networkClient: NetworkClient
    
    init (networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchAllCategories() async throws -> [Category] {
        let config = GetCategoriesConfig()
        return try await networkClient.request(config: config, responseType: [Category].self)
    }

    func fetchCategoriesByDirection(for direction: Direction) async throws -> [Category] {
        struct GetCategoriesByDirectionConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String
            let method: HTTPMethod = .get
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody? = nil
            
            init(direction: Direction) {
                let isIncome = direction.isIncome ? "true" : "false"
                self.path = "/categories/type/\(isIncome)"
            }
        }

        let config = GetCategoriesByDirectionConfig(direction: direction)
        return try await networkClient.request(config: config, responseType: [Category].self)
    }
}
