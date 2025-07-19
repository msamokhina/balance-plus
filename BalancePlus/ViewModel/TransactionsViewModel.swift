import Foundation

struct TransactionViewModel: Identifiable {
    let id: Int
    let amount: Decimal
    let amountStr: String
    let date: Date
    let dateStr: String
    let comment: String?
    let categoryEmoji: Character
    let categoryName: String
    let direction: Direction
}

@Observable
final class TransactionsViewModel {
    let historyViewModel: HistoryViewModel
    var editTransactionViewModel: EditTransactionViewModel
    var createTransactionViewModel: CreateTransactionViewModel
    var transactions: [TransactionViewModel] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    var account: BankAccount?
    var showingAlert: Bool = false
    let service: TransactionsServiceProtocol
    let accountService: BankAccountServiceProtocol
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
    let direction: Direction
    
    var selectedStartDate: Date
    var selectedEndDate: Date
    
    private static func amountConverter(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter.string(from: value as NSDecimalNumber) ?? value.description
    }
    
    init(direction: Direction,
         selectedStartDate: Date = Date().startOfDay(),
         selectedEndDate: Date = Date().endOfDay(),
         service: TransactionsServiceProtocol,
         accountService: BankAccountServiceProtocol,
         editTransactionViewModel: EditTransactionViewModel,
         createTransactionViewModel: CreateTransactionViewModel,
         historyViewModel: HistoryViewModel
    ) {
        self.direction = direction
        self.selectedStartDate = selectedStartDate
        self.selectedEndDate = selectedEndDate
        self.service = service
        self.accountService = accountService
        self.editTransactionViewModel = editTransactionViewModel
        self.createTransactionViewModel = createTransactionViewModel
        
        self.historyViewModel = historyViewModel
    }
    
    var sum: String {
        return "\(TransactionsViewModel.amountConverter(transactions.map {$0.amount}.reduce(0, +))) \(account?.currency.symbol ?? Currency.rub.symbol)"
    }
    
    @MainActor
    func loadTransactions() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedAccount = try await accountService.fetchUserBankAccount()
                account = fetchedAccount
                let fetchedTransactions = try await service.fetchTransactions(accountId: fetchedAccount.id, from: selectedStartDate, to: selectedEndDate)
                transactions = fetchedTransactions.filter { $0.category.direction == direction }.map{convert($0)}
                isLoading = false
            } catch {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Не удалось загрузить транзакции"
                }
                showingAlert = true
                isLoading = false
            }
        }
    }
}
