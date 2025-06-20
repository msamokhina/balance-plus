import Foundation

struct TransactionViewModel: Identifiable {
    let id: Int
    let amount: Decimal
    let amountStr: String
    let transactionDate: Date
    let date: String
    let comment: String?
    let categoryEmoji: Character
    let categoryName: String
    let direction: Direction
}

enum TransactionsSort {
    case byDate
    case byAmount
}

@Observable
final class TransactionsViewModel {
    var transactions: [TransactionViewModel] = []
    var isLoading: Bool = false
    var errorMessage: String?
    private(set) var sort: TransactionsSort = .byDate
    
    private let provider: TransactionsServiceProtocol
    private let convert: (Transaction) -> TransactionViewModel = {
        transaction in TransactionViewModel(
            id: transaction.id,
            amount: transaction.amount,
            amountStr: "\(Int(truncating: NSDecimalNumber(decimal: transaction.amount)).formattedWithGroupSeparator()) ₽",
            transactionDate: transaction.transactionDate,
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
    
    func sortTransactions(sortBy: TransactionsSort = .byDate) {
        if sortBy == .byDate {
            // По дате сортируем по убыванию, сверху всегда более свежие оперции
            transactions = transactions.sorted { $0.transactionDate < $1.transactionDate }
            sort = .byDate
        } else {
            // По цене сортируем по возрастанию, предполагаю, что пользователю в первую очередь интересны крупные расходы
            transactions = transactions.sorted { $0.amount > $1.amount }
            sort = .byAmount
        }
    }
    
    @MainActor
    func loadTransactions() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedTransactions = try await provider.fetchTransactions(from: selectedStartDate, to: selectedEndDate)
                transactions = fetchedTransactions.filter { $0.category.direction == direction }.map{convert($0)}
                self.sortTransactions(sortBy: .byDate)
                isLoading = false
            } catch {
                errorMessage = "Не удалось загрузить транзакции"
                isLoading = false
            }
        }
    }
}
