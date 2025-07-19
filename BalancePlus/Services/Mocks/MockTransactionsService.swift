import Foundation

enum TransactionsSortType: CaseIterable {
    case byDate
    case byAmount
    
    var name: String {
        switch self {
        case .byDate: return "По дате"
        case .byAmount: return "По сумме"
        }
    }
}

final class MockTransactionsService: TransactionsServiceProtocol {
    private(set) var mockTransactions: [Transaction] = []
    private var nextID: Int = 0 // Для генерации уникальных ID для новых транзакций

    private let mockAccount = BankAccount(
        id: 0, userId: 0, name: "Основной счёт", balance: 1000.00, currency: .rub,
        createdAt: Date().addingTimeInterval(-86400 * 30), updatedAt: Date().addingTimeInterval(-86400 * 30)
    )
    
    private let mockSalaryCategory = Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income)
    private let mockFoodCategory = Category(id: 101, name: "Еда и продукты", emoji: "🍔", direction: .outcome)
    private let mockTransportCategory = Category(id: 102, name: "Транспорт", emoji: "🚗", direction: .outcome)
    
    // Инициализатор, который заполняет моковые данные при создании сервиса
    init() {
        setupInitialMockData()
    }

    private func setupInitialMockData() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Создаем несколько стартовых транзакций
        let now = Date()
        let oneDayAgo = now.addingTimeInterval(-24 * 60 * 60)
        let twoDaysAgo = now.addingTimeInterval(-2 * 24 * 60 * 60)
        let threeDaysAgo = now.addingTimeInterval(-3 * 24 * 60 * 60)
        let tenDaysAgo = now.addingTimeInterval(-10 * 24 * 60 * 60)
        let twentyDaysAgo = now.addingTimeInterval(-20 * 24 * 60 * 60)
        let fourtyDaysAgo = now.addingTimeInterval(-40 * 24 * 60 * 60)


        mockTransactions = [
            Transaction(
                id: nextID, account: mockAccount, category: mockSalaryCategory, amount: 52000.00,
                transactionDate: now, comment: nil, createdAt: tenDaysAgo, updatedAt: tenDaysAgo
            ),
            Transaction(
                id: nextID + 1, account: mockAccount, category: mockFoodCategory, amount: 750.50,
                transactionDate: now, comment: "Продукты из супермаркета", createdAt: threeDaysAgo, updatedAt: threeDaysAgo
            ),
            Transaction(
                id: nextID + 2, account: mockAccount, category: mockTransportCategory, amount: 90.00,
                transactionDate: now, comment: "Поездка на метро", createdAt: twoDaysAgo, updatedAt: twoDaysAgo
            ),
            Transaction(
                id: nextID + 3, account: mockAccount, category: mockFoodCategory, amount: 950.00,
                transactionDate: oneDayAgo, comment: "Обед в кафе", createdAt: oneDayAgo, updatedAt: oneDayAgo
            ),
            Transaction(
                id: nextID + 4, account: mockAccount, category: mockSalaryCategory, amount: 5000.00,
                transactionDate: now, comment: "Премия", createdAt: now, updatedAt: now
            ),
            Transaction(
                id: nextID + 5, account: mockAccount, category: mockSalaryCategory, amount: 50000.00,
                transactionDate: fourtyDaysAgo, comment: "Зарплата за май", createdAt: now, updatedAt: now
            ),
            Transaction(
                id: nextID + 6, account: mockAccount, category: mockSalaryCategory, amount: 51000.00,
                transactionDate: twentyDaysAgo, comment: "Аванс за июнь", createdAt: now, updatedAt: now
            )
        ]
        nextID += mockTransactions.count
    }

    func fetchTransactions(accountId: Int = 0, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        return mockTransactions.filter { transaction in
            transaction.transactionDate >= startDate && transaction.transactionDate <= endDate
        }.sorted { $0.transactionDate < $1.transactionDate }
    }
    
    func fetchTransaction(id: Int) async throws -> Transaction {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return mockTransactions.first(where: { $0.id == id })!
    }
    
    func createTransaction(accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String) async throws {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        mockTransactions[0]
    }

    func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            // Если транзакция не найдена, выбрасываем ошибку
            throw MockServiceError.notFound(message: "Транзакция с ID \(transaction.id) не найдена для обновления")
        }

        var updatedTransaction = transaction
        updatedTransaction.updatedAt = Date() // Обновляем время последнего изменения

        mockTransactions[index] = updatedTransaction
        print("MockTransactionsService: Транзакция с ID \(updatedTransaction.id) обновлена")
        return updatedTransaction
    }

    func deleteTransaction(id: Int) async throws {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        let initialCount = mockTransactions.count
        mockTransactions.removeAll { $0.id == id }

        if mockTransactions.count == initialCount {
            // Если количество транзакций не изменилось, значит, транзакция не была найдена
            throw MockServiceError.notFound(message: "Транзакция с ID \(id) не найдена для удаления")
        }
        print("MockTransactionsService: Транзакция с ID \(id) удалена")
    }
}

enum MockServiceError: Error {
    case notFound(message: String)

    var errorDescription: String? {
        switch self {
        case .notFound(let message):
            return "Не найдено: \(message)"
        }
    }
}
