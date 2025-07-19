import Foundation

protocol TransactionsServiceProtocol {
    func fetchTransactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func fetchTransaction(id: Int) async throws -> Transaction
    func createTransaction(accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String) async throws
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction
    func deleteTransaction(id: Int) async throws
}

struct GetTransactionsRequestBody: RequestBody {
    let startDate: Date
    let endDate: Date
}

final class TransactionsService: TransactionsServiceProtocol {
    private let networkClient: NetworkClient
    
    init (networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    var mockTransactions: [Transaction] = []
    
    func fetchTransactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        struct GetTransactionsConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String
            let method: HTTPMethod = .get
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody? = nil
            
            init(accountId: Int, startDate: Date, endDate: Date) {
                self.path = "/transactions/account/\(accountId)/period"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                self.queryParameters = ["startDate": dateFormatter.string(from: startDate), "endDate": dateFormatter.string(from: endDate)]
            }
        }
        
        let config = GetTransactionsConfig(accountId: accountId, startDate: startDate, endDate: endDate)
        return try await networkClient.request(config: config, responseType: [Transaction].self)
    }
    
    func fetchTransaction(id: Int) async throws -> Transaction {
        struct GetTransactionConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String
            let method: HTTPMethod = .get
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody? = nil
            
            init(id: Int) {
                self.path = "/transactions/\(id)"
            }
        }
        
        let config = GetTransactionConfig(id: id)
        return try await networkClient.request(config: config, responseType: Transaction.self)
    }
    
    func createTransaction(accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String) async throws {
        struct PostTransactionConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String = "/transactions"
            let method: HTTPMethod = .post
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody? = nil
            
            struct PostTransactionRequest: RequestBody {
                let accountId: Int
                let categoryId: Int
                let amount: String
                let transactionDate: String
                let comment: String
            }
            
            init(accountId: Int, categoryId: Int, amount: String, transactionDate: String, comment: String) {
                self.body = PostTransactionRequest(accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment)
            }
        }
        
        let dateFormatter = ISO8601DateFormatter.withFractionalSeconds
        
        let config = PostTransactionConfig(
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: "\(dateFormatter.string(from: transactionDate))",
            comment: comment
        )
        let _ = try await networkClient.request(config: config, responseType: TransactionCreated.self)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        struct PutTransactionConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String
            let method: HTTPMethod = .put
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody?
            
            struct UpdateTransactionRequest: RequestBody {
                let accountId: Int
                let categoryId: Int
                let amount: String
                let transactionDate: String
                let comment: String
            }
            
            init(transactionId: Int, accountId: Int, categoryId: Int, amount: String, transactionDate: String, comment: String) {
                self.path = "/transactions/\(transactionId)"

                self.body = UpdateTransactionRequest(accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment)
            }
        }
        
        let dateFormatter = ISO8601DateFormatter.withFractionalSeconds

        let config = PutTransactionConfig(
            transactionId: transaction.id,
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount.description,
            transactionDate: "\(dateFormatter.string(from: transaction.transactionDate))",
            comment: "\(transaction.comment ?? "")"
        )
        return try await networkClient.request(config: config, responseType: Transaction.self)
    }
    
    func deleteTransaction(id: Int) async throws {
        struct DeleteTransactionConfig: RequestConfiguration {
            let baseURL: URL = APIConfig.baseURL
            let path: String
            let method: HTTPMethod = .delete
            var headers: [String: String]? = nil
            var queryParameters: [String: String]? = nil
            var body: RequestBody? = nil
            
            init(id: Int) {
                self.path = "/transactions/\(id)"
            }
        }
        
        let config = DeleteTransactionConfig(id: id)
        let _ = try await networkClient.request(config: config, responseType: EmptyResponse.self)
    }
}
