import Foundation

/// Протокол, определяющий интерфейс для работы со счетами
protocol BankAccountsServiceProtocol {
    /// Получает единственный счет пользователя
    /// Если счетов несколько, берем первый
    /// - Returns: Объект `BankAccount?` (первый счёт, или `nil`, если счетов нет)
    /// - Throws: Ошибки, связанные с получением данных
    func fetchUserBankAccount() async throws -> BankAccount?

    /// Обновляет информацию о банковском счёте
    /// - Parameter bankAccount: Объект `BankAccount` с обновленными данными
    /// - Returns: Обновленный `BankAccount` (или `nil`, если обновление не удалось)
    /// - Throws: Ошибки, связанные с операцией обновления
    func updateBankAccount(_ bankAccount: BankAccount) async throws -> BankAccount?
}

/// Мок сервиса счетов
/// Предоставляет заранее определенный набор данных и имитирует обновление
final class MockBankAccountsService: BankAccountsServiceProtocol {
    @Published private var mockBankAccounts: [BankAccount] = [
        BankAccount(
            id: 1,
            userId: 1,
            name: "Основной счёт",
            balance: 1000.00,
            currency: .rub,
            createdAt: ISO8601DateFormatter().date(from: "2025-06-01T10:00:00.000Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-01T10:00:00.000Z")!
        ),
        BankAccount(
            id: 2,
            userId: 1,
            name: "Сберегательный счёт",
            balance: 5000.00,
            currency: .rub,
            createdAt: ISO8601DateFormatter().date(from: "2025-05-15T09:00:00.000Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-05-15T09:00:00.000Z")!
        ),
        BankAccount(
            id: 3,
            userId: 1,
            name: "Евро счёт",
            balance: 200.00,
            currency: .eur,
            createdAt: ISO8601DateFormatter().date(from: "2025-06-05T12:00:00.000Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-05T12:00:00.000Z")!
        )
    ]

    /// Имитирует асинхронное получение единственного счета
    /// Всегда возвращает первый счет из `mockBankAccounts`
    func fetchUserBankAccount() async throws -> BankAccount? {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        return mockBankAccounts.first
    }

    /// Имитирует асинхронное обновление счета
    /// Находит счет по `id` и заменяет его
    func updateBankAccount(_ bankAccount: BankAccount) async throws -> BankAccount? {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        if let index = mockBankAccounts.firstIndex(where: { $0.id == bankAccount.id }) {
            mockBankAccounts[index] = bankAccount
            print("MockBankAccountsService: Счёт с ID \(bankAccount.id) обновлён. Новый баланс: \(bankAccount.balance)")
            return bankAccount
        } else {
            print("MockBankAccountsService: Счёт с ID \(bankAccount.id) не найден для обновления")
            return nil
        }
    }
}
