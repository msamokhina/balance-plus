import Foundation

/// Протокол, определяющий интерфейс для работы с финансовыми транзакциями
protocol TransactionsServiceProtocol {
    /// Получает список транзакций за указанный период
    /// - Parameters:
    ///   - startDate: Начальная дата периода (включительно)
    ///   - endDate: Конечная дата периода (включительно)
    /// - Returns: Массив объектов `Transaction`, соответствующих заданному периоду
    /// - Throws: Ошибки, связанные с получением данных
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction]

    /// Создаёт новую транзакцию
    /// - Parameter transaction: Объект `Transaction` для создания
    /// - Returns: Созданный объект `Transaction` с присвоенным уникальным ID и временными метками
    /// - Throws: Ошибки, связанные с операцией создания
    func createTransaction(_ transaction: Transaction) async throws -> Transaction

    /// Редактирует существующую транзакцию
    /// - Parameter transaction: Объект `Transaction` с обновленными данными
    /// - Returns: Обновленный объект `Transaction`
    /// - Throws: Ошибки, если транзакция не найдена или другие проблемы
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction

    /// Удаляет транзакцию по её идентификатору
    /// - Parameter transactionID: Идентификатор транзакции, которую нужно удалить
    /// - Throws: Ошибки, если транзакция не найдена или другие проблемы
    func deleteTransaction(withID transactionID: Int) async throws
}

/// Мок сервиса транзакций
/// Имитирует CRUD-операции (создание, чтение, обновление, удаление) над транзакциями
final class MockTransactionsService: TransactionsServiceProtocol {
    @Published private var mockTransactions: [Transaction] = []
    private var nextID: Int = 0 // Для генерации уникальных ID для новых транзакций

    private let mockAccount = BankAccount(
        id: 0, userId: 0, name: "Основной счёт", balance: 1000.00, currency: .rub,
        createdAt: Date().addingTimeInterval(-86400 * 30), updatedAt: Date().addingTimeInterval(-86400 * 30)
    )
    
    private let mockSalaryCategory = Category(id: 100, name: "Зарплата", emoji: "💰", direction: .income)
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


        mockTransactions = [
            Transaction(
                id: nextID, account: mockAccount, category: mockSalaryCategory, amount: 50000.00,
                transactionDate: tenDaysAgo, comment: "Зарплата за май", createdAt: tenDaysAgo, updatedAt: tenDaysAgo
            ),
            Transaction(
                id: nextID + 1, account: mockAccount, category: mockFoodCategory, amount: 750.50,
                transactionDate: threeDaysAgo, comment: "Продукты из супермаркета", createdAt: threeDaysAgo, updatedAt: threeDaysAgo
            ),
            Transaction(
                id: nextID + 2, account: mockAccount, category: mockTransportCategory, amount: 90.00,
                transactionDate: twoDaysAgo, comment: "Поездка на метро", createdAt: twoDaysAgo, updatedAt: twoDaysAgo
            ),
            Transaction(
                id: nextID + 3, account: mockAccount, category: mockFoodCategory, amount: 950.00,
                transactionDate: oneDayAgo, comment: "Обед в кафе", createdAt: oneDayAgo, updatedAt: oneDayAgo
            ),
            Transaction(
                id: nextID + 4, account: mockAccount, category: mockSalaryCategory, amount: 5000.00,
                transactionDate: now, comment: "Премия", createdAt: now, updatedAt: now
            )
        ]
        nextID += mockTransactions.count
    }


    /// Имитирует получение транзакций за указанный период
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        return mockTransactions.filter { transaction in
            transaction.transactionDate >= startDate && transaction.transactionDate <= endDate
        }
    }

    /// Имитирует создание новой транзакции
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        let newTransaction = Transaction(
            id: nextID,
            account: transaction.account,
            category: transaction.category,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: Date(),
            updatedAt: Date()
        )

        mockTransactions.append(newTransaction)
        nextID += 1
        print("MockTransactionsService: Создана новая транзакция с ID \(newTransaction.id)")
        return newTransaction
    }

    /// Имитирует обновление существующей транзакции
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

    /// Имитирует удаление транзакции по ID
    func deleteTransaction(withID transactionID: Int) async throws {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        let initialCount = mockTransactions.count
        mockTransactions.removeAll { $0.id == transactionID }

        if mockTransactions.count == initialCount {
            // Если количество транзакций не изменилось, значит, транзакция не была найдена
            throw MockServiceError.notFound(message: "Транзакция с ID \(transactionID) не найдена для удаления")
        }
        print("MockTransactionsService: Транзакция с ID \(transactionID) удалена")
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
