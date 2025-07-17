import Foundation

protocol BankAccountServiceProtocol {
    func fetchUserBankAccount() async throws -> BankAccount
    func updateBankAccount(id: Int, name: String, balance: Decimal, currency: Currency) async throws -> BankAccount
}

struct GetAccountsConfig: RequestConfiguration {
    let baseURL: URL = APIConfig.baseURL
    let path: String = "/accounts"
    let method: HTTPMethod = .get
    var headers: [String: String]? = nil
    var queryParameters: [String: String]? = nil
    var body: RequestBody? = nil
}

struct UpdateBankAccountRequest: RequestBody {
    let name: String
    let balance: String
    let currency: String
}

final class BankAccountService: BankAccountServiceProtocol {
    private let networkClient: NetworkClient
    
    init (networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchUserBankAccount() async throws -> BankAccount {
        let config = GetAccountsConfig()
        return try await networkClient.request(config: config, responseType: [BankAccount].self).first!
    }

    func updateBankAccount(id: Int, name: String, balance: Decimal, currency: Currency) async throws -> BankAccount {
        struct PutAccountConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String
            let method: HTTPMethod = .put
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody? = nil
            
            init(id: Int, name: String, balance: String, currency: String) {
                self.path = "/accounts/\(id)"
                self.body = UpdateBankAccountRequest(name: name, balance: balance, currency: currency)
            }
        }
        
        let config = PutAccountConfig(id: id, name: name, balance: balance.description, currency: currency.rawValue)
        return try await networkClient.request(config: config, responseType: BankAccount.self)
    }
}

