import Foundation

struct TransactionViewModel: Identifiable {
    let id: Int
    let amount: Decimal
    let amountStr: String
    let date: String
    let comment: String?
    let categoryEmoji: Character
    let categoryName: String
    let direction: Direction
}

@Observable
final class TransactionsViewModel {
    var transactions: [TransactionViewModel] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let provider: TransactionsServiceProtocol
    private let convert: (Transaction) -> TransactionViewModel = {
        transaction in TransactionViewModel(
            id: transaction.id,
            amount: transaction.amount,
            amountStr: "\(Int(truncating: NSDecimalNumber(decimal: transaction.amount)).formattedWithGroupSeparator()) ₽",
            date: "\(transaction.transactionDate)",
            comment: transaction.comment,
            categoryEmoji: transaction.category.emoji,
            categoryName: transaction.category.name,
            direction: transaction.category.direction
        )
    }
    let direction: Direction
    
    var selectedStartDate: Date
    var selectedEndDate: Date
    
    init(direction: Direction,
         selectedStartDate: Date = Date().startOfDay(),
         selectedEndDate: Date = Date().endOfDay(),
         provider: TransactionsServiceProtocol = MockTransactionsService()
    ) {
        self.direction = direction
        self.selectedStartDate = selectedStartDate
        self.selectedEndDate = selectedEndDate
        self.provider = provider
    }
    
    var sum: String {
        let sum = Int(truncating: NSDecimalNumber(decimal: transactions.map {$0.amount}.reduce(0, +)))
        return "\(sum.formattedWithGroupSeparator()) ₽"
    }
    
    @MainActor
    func loadTransactions() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedTransactions = try await provider.fetchTransactions(from: selectedStartDate, to: selectedEndDate)
                transactions = fetchedTransactions.filter { $0.category.direction == direction }.map{convert($0)}
                isLoading = false
            } catch {
                errorMessage = "Не удалось загрузить транзакции"
                isLoading = false
            }
        }
    }
}
