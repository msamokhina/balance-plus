import SwiftUI

@Observable
final class AccountViewModel {
    var balance: String
    var currency: String
    var mode: AccountViewMode
    private let provider: BankAccountsServiceProtocol

    init(balance: String = "0",
         currency: String = "₽",
         mode: AccountViewMode = .read,
         provider: BankAccountsServiceProtocol = MockBankAccountsService()) {
        self.balance = balance
        self.currency = currency
        self.mode = mode
        self.provider = provider
    }

    func onEdit() {
        mode = .write
    }
    
    func onSave() {
        Task {
            await updateBankAccount()
        }
    }
    
    @MainActor
    func updateBankAccount() {
        let groupingSeparator: String = Locale.current.groupingSeparator ?? " "
        let newBalance = Decimal(string: balance.replacingOccurrences(of: groupingSeparator, with: "")) ?? Decimal(0)
        
        let newCurrency = Currency(symbol: currency)
        
        Task {
            do {
                let updatedAccount = try await provider.updateBankAccount(currency: newCurrency, balance: newBalance)
                
                self.balance = Int(truncating: NSDecimalNumber(decimal: updatedAccount.balance)).formatted()
                self.currency = updatedAccount.currency.symbol
                self.mode = .read
            } catch {}
        }
    }
    
    @MainActor
    func loadBalance() async {
        let prevMode = self.mode
        self.mode = .loading
        
        // Делаем минимальную задержку чтобы на pull to refresh лоадер не дергался и быстро не исчезал
        let startTime = Date()
        let minimumDisplayDuration: TimeInterval = 0.9
        do {
            let fetchedAccount = try await provider.fetchUserBankAccount()
            let endTime = Date()
            let elapsedTime = endTime.timeIntervalSince(startTime) // Сколько времени занял запрос

            if elapsedTime < minimumDisplayDuration {
                try await Task.sleep(for: .seconds(minimumDisplayDuration - elapsedTime))
            }
            self.mode = prevMode
            self.balance = Int(truncating: NSDecimalNumber(decimal: fetchedAccount.balance)).formatted()
            self.currency = fetchedAccount.currency.symbol
        } catch {}
    }
}
