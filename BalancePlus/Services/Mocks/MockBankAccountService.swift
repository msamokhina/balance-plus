import Foundation

protocol BankAccountsServiceProtocol {
    func fetchUserBankAccount() async throws -> BankAccount
    func updateBankAccount(currency: Currency, balance: Decimal) async throws -> BankAccount
}

final class MockBankAccountsService: BankAccountsServiceProtocol {
    private static let formatter = ISO8601DateFormatter.withFractionalSeconds
    @Published private var mockBankAccounts: [BankAccount] = [
        BankAccount(
            id: 1,
            userId: 1,
            name: "Основной счёт",
            balance: Decimal(1000.00),
            currency: .rub,
            createdAt: formatter.date(from: "2025-06-01T10:00:00.000Z") ?? Date(),
            updatedAt: formatter.date(from: "2025-06-01T10:00:00.000Z") ?? Date()
        ),
        BankAccount(
            id: 2,
            userId: 1,
            name: "Сберегательный счёт",
            balance: Decimal(1000.00),
            currency: .rub,
            createdAt: ISO8601DateFormatter().date(from: "2025-05-15T09:00:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-05-15T09:00:00.000Z") ?? Date()
        ),
        BankAccount(
            id: 3,
            userId: 1,
            name: "Евро счёт",
            balance: Decimal(1000.00),
            currency: .eur,
            createdAt: ISO8601DateFormatter().date(from: "2025-06-05T12:00:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-05T12:00:00.000Z") ?? Date()
        )
    ]

    func fetchUserBankAccount() async throws -> BankAccount {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        return mockBankAccounts.first!
    }

    func updateBankAccount(currency: Currency, balance: Decimal) async throws -> BankAccount {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды

        mockBankAccounts[0].currency = currency
        mockBankAccounts[0].balance = balance
    
        return mockBankAccounts[0]
    }
}
