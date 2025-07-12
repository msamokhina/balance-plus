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

enum SortBy {
    case byDate
    case byAmount
}

@Observable
final class TransactionsViewModel {
    var editTransactionViewModel: EditTransactionViewModel
    var createTransactionViewModel: CreateTransactionViewModel
    var transactions: [TransactionViewModel] = []
    var isLoading: Bool = false
    var errorMessage: String?
    private(set) var sort: SortBy = .byDate
    
    let service: TransactionsServiceProtocol
    private let convert: (Transaction) -> TransactionViewModel = {
        transaction in TransactionViewModel(
            id: transaction.id,
            amount: transaction.amount,
            amountStr: "\(Int(truncating: NSDecimalNumber(decimal: transaction.amount)).formatted()) \(transaction.account.currency.symbol)",
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
    
    init(direction: Direction,
         selectedStartDate: Date = Date().startOfDay(),
         selectedEndDate: Date = Date().endOfDay(),
         service: TransactionsServiceProtocol,
         editTransactionViewModel: EditTransactionViewModel,
         createTransactionViewModel: CreateTransactionViewModel
    ) {
        self.direction = direction
        self.selectedStartDate = selectedStartDate
        self.selectedEndDate = selectedEndDate
        self.service = service
        self.editTransactionViewModel = editTransactionViewModel
        self.createTransactionViewModel = createTransactionViewModel
    }
    
    var sum: String {
        let sum = Int(truncating: NSDecimalNumber(decimal: transactions.map {$0.amount}.reduce(0, +)))
        return "\(sum.formatted()) ₽"
    }
    
    func sortTransactions(sortBy: SortBy = .byDate) {
        if sortBy == .byDate {
            // По дате сортируем по убыванию, сверху всегда более свежие оперции
            transactions = transactions.sorted { $0.date < $1.date }
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
                let fetchedTransactions = try await service.fetchTransactions(from: selectedStartDate, to: selectedEndDate)
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
