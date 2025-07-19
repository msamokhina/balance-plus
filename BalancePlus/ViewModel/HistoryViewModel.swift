import Foundation

enum SortBy {
    case byDate
    case byAmount
}

@Observable
final class HistoryViewModel {
    enum State {
        case processing(ProcessingViewModel)
        case error(ErrorViewModel)
        case idle(IdleStateViewModel)
    }
    
    var state: State
    var editTransactionViewModel: EditTransactionViewModel
    
    var selectedStartDate: Date
    var selectedEndDate: Date
    var sort: SortBy = .byDate
    let direction: Direction
    let transactionsService: TransactionsServiceProtocol
    let accountService: BankAccountServiceProtocol
    var transactions: [Transaction] = []
    var account: BankAccount?
    
    var showingAlert: Bool = false
    
    private let convert: (Transaction) -> TransactionViewModel = {
        transaction in TransactionViewModel(
            id: transaction.id,
            amount: transaction.amount,
            amountStr: "\(amountConverter(transaction.amount)) \(transaction.account.currency.symbol)",
            date: transaction.transactionDate,
            dateStr: "\(transaction.transactionDate)",
            comment: transaction.comment,
            categoryEmoji: transaction.category.emoji,
            categoryName: transaction.category.name,
            direction: transaction.category.direction
        )
    }
    
    private static func amountConverter(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter.string(from: value as NSDecimalNumber) ?? value.description
    }
    
    init (state: State,
          direction: Direction,
          selectedStartDate: Date,
          selectedEndDate: Date,
          transactionsService: TransactionsServiceProtocol,
          accountService: BankAccountServiceProtocol,
          editTransactionViewModel: EditTransactionViewModel
    ) {
        self.state = state
        self.direction = direction
        self.selectedStartDate = selectedStartDate
        self.selectedEndDate = selectedEndDate
        self.transactionsService = transactionsService
        self.accountService = accountService
        self.editTransactionViewModel = editTransactionViewModel
    }
    
    func sortTransactions() {
        var sortedTransactions: [Transaction] = []
        if sort == .byDate {
            // По дате сортируем по убыванию, сверху всегда более свежие оперции
            sortedTransactions = transactions.sorted { $0.transactionDate < $1.transactionDate }
            sort = .byDate
        } else {
            // По цене сортируем по возрастанию, предполагаю, что пользователю в первую очередь интересны крупные расходы
            sortedTransactions = transactions.sorted { $0.amount > $1.amount }
            sort = .byAmount
        }
        
        transactions = sortedTransactions
    }
    
    func onSort(sortBy: SortBy) {
        sort = sortBy
        guard case .idle(_) = state else { return }

        sortTransactions()
        let totalAmount = "\(HistoryViewModel.amountConverter(transactions.reduce(0) { $0 + $1.amount })) \(account?.currency.symbol ?? Currency.rub.symbol)"
        let transactionsViewModels: [TransactionViewModel] = transactions.map{convert($0)}
        state = .idle(IdleStateViewModel(transactions: transactionsViewModels, totalAmount: totalAmount))
    }
    
    @MainActor
    func loadTransactions () {
        state = .processing(ProcessingViewModel(reason: .loading))
        Task {
            do {
                let fetchedAccount = try await accountService.fetchUserBankAccount()
                account = fetchedAccount
                let fetchedTransactions = try await transactionsService.fetchTransactions(accountId: fetchedAccount.id, from: selectedStartDate, to: selectedEndDate)
                transactions = fetchedTransactions.filter { $0.category.direction == direction }
                sortTransactions()
                
                let totalAmount = "\(HistoryViewModel.amountConverter(transactions.reduce(0) { $0 + $1.amount })) \(fetchedAccount.currency.symbol)"
                let transactionsViewModels: [TransactionViewModel] = transactions.map{convert($0)}
                
                state = .idle(IdleStateViewModel(transactions: transactionsViewModels, totalAmount: totalAmount))
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

enum ProcessingHistoryReason: String {
    case loading
    case updating
    
    var transactionsText: String {
        switch self {
        case .loading: return "Загрузка транзакций..."
        case .updating: return "Обновление транзакций..."
        }
    }
    
    var balanceText: String {
        switch self {
        case .loading: return "Загрузка..."
        case .updating: return "Обновление..."
        }
    }
}

extension HistoryViewModel {
    final class ProcessingViewModel {
        let reason: ProcessingHistoryReason
        
        init(reason: ProcessingHistoryReason) {
            self.reason = reason
        }
    }
    
    final class ErrorViewModel {
        let message: String
        
        init(message: String) {
            self.message = message
        }
    }
    
    @Observable
    final class IdleStateViewModel {
        var transactions: [TransactionViewModel]
        var totalAmount: String
        
        init (transactions: [TransactionViewModel], totalAmount: String) {
            self.transactions = transactions
            self.totalAmount = totalAmount
        }
    }
}
