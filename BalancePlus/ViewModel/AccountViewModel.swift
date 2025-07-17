import SwiftUI

protocol BalanceConverterProtocol {
    func convert(_ value: Decimal) -> String
    func convert(_ value: String) -> Decimal
}

struct BalanceConverter: BalanceConverterProtocol {
    func convert(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter.string(from: value as NSDecimalNumber) ?? value.description
    }

    func convert(_ value: String) -> Decimal {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        return formatter.number(from: value)?.decimalValue ?? .zero
    }
}

@Observable
final class AccountViewModel {
    enum State {
        case processing(ProcessingViewModel)
        case error(ErrorViewModel)
        case idle(IdleStateViewModel)
        case editing(EditingStateViewModel)
    }

    var state: State
    private let service: BankAccountServiceProtocol

    var showingAlert: Bool = false
    
    var bankAccount: BankAccount?
    private let balanceConverter: BalanceConverterProtocol
    
    init(state: State, service: BankAccountServiceProtocol) {
        self.state = state
        self.service = service
        self.balanceConverter = BalanceConverter()
    }

    func onEdit() {
        guard case .idle(let idleViewModel) = state else { return }

        state = .editing(EditingStateViewModel(
            balance: idleViewModel.balance,
            currency: idleViewModel.currency))
    }

    @MainActor
    func onSave() {
        guard case .editing(let editingViewModel) = state else { return }

        let newCurrency = editingViewModel.currency
        let newBalance = editingViewModel.balance
        
        // если изменений нет, на сервер не идем
        if newCurrency == bankAccount?.currency &&
            balanceConverter.convert(newBalance) == bankAccount?.balance {
            state = .idle(IdleStateViewModel(
                currency: newCurrency,
                balance: newBalance
            ))
            
            return
        }
        
        state = .processing(ProcessingViewModel(reason: .saving))
        Task {
            do {
                let updatedBankAccount = try await service.updateBankAccount(
                    id: bankAccount!.id,
                    name: bankAccount!.name,
                    balance: balanceConverter.convert(newBalance),
                    currency: newCurrency
                )
                
                state = .idle(IdleStateViewModel(
                    currency: newCurrency,
                    balance: balanceConverter.convert(updatedBankAccount.balance)
                ))
            } catch {
                if let networkError = error as? NetworkError {
                    state = .error(ErrorViewModel(message: networkError.localizedDescription))
                } else {
                    state = .error(ErrorViewModel(message: "Произошла непредвиденная ошибка."))
                }
                showingAlert = true
            }
        }
    }
    
    @MainActor
    func onRefresh() {
        Task {
            do {
                let fetchedBankAccount = try await service.fetchUserBankAccount()
                bankAccount = fetchedBankAccount
                state = .idle(IdleStateViewModel(
                    currency: fetchedBankAccount.currency,
                    balance: self.balanceConverter.convert(fetchedBankAccount.balance)
                ))
            } catch {
                if let networkError = error as? NetworkError {
                    state = .error(ErrorViewModel(message: networkError.localizedDescription))
                } else {
                    state = .error(ErrorViewModel(message: "Произошла непредвиденная ошибка."))
                }
                showingAlert = true
            }
        }
    }
    
    @MainActor
    func loadBankAccount() {
        state = .processing(ProcessingViewModel(reason: .loading))
        
        Task {
            do {
                let fetchedBankAccount = try await service.fetchUserBankAccount()
                bankAccount = fetchedBankAccount
                state = .idle(IdleStateViewModel(
                    currency: fetchedBankAccount.currency,
                    balance: self.balanceConverter.convert(fetchedBankAccount.balance)
                ))
            } catch {
                if let networkError = error as? NetworkError {
                    state = .error(ErrorViewModel(message: networkError.localizedDescription))
                } else {
                    state = .error(ErrorViewModel(message: "Произошла непредвиденная ошибка."))
                }
                showingAlert = true
            }
        }
    }
}

enum ProcessingAccountReason: String {
    case loading
    case saving
    
    var text: String {
        switch self {
        case .loading: return "Загрузка счета..."
        case .saving: return "Сохранение счета..."
        }
    }
}

extension AccountViewModel {
    final class ProcessingViewModel {
        let reason: ProcessingAccountReason
        
        init(reason: ProcessingAccountReason) {
            self.reason = reason
        }
    }
    
    final class ErrorViewModel {
        let message: String
        
        init(message: String) {
            self.message = message
        }
    }
    
    final class IdleStateViewModel {
        var balance: String = "1000"
        var currency: Currency

        init(currency: Currency, balance: String) {
            self.currency = currency
            self.balance = balance
        }
    }

    @Observable
    final class EditingStateViewModel {
        var balance: String
        var currency: Currency

        init(balance: String, currency: Currency) {
            self.balance = balance
            self.currency = currency
        }

    }
}
