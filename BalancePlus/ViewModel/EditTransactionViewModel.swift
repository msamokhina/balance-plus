import Foundation

@Observable
final class EditTransactionViewModel {
    let transactionsService: TransactionsServiceProtocol
    let categoriesService: CategoriesServiceProtocol
    var showingDetailSheet = false
    var title = "Редактировать"
    var transaction: Transaction?
    var categories: [Category] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    var commentField: String = ""
    var amountField: String = ""
    var categoryField: Category?
    var dateField: Date = Date()
    
    init(
         transactionsService: TransactionsServiceProtocol,
         categoriesService: CategoriesServiceProtocol
    ) {
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
    }
    
    @MainActor
    func show(transactionId: Int, direction: Direction) {
        errorMessage = nil
        showingDetailSheet = true
        fetchCategoriesByDirection(direction: direction)
        transaction = transactionsService.mockTransactions.first(where: { $0.id == transactionId })
        setFields(transaction)
        setTitle(direction: direction)
    }

    func dismiss() {
        showingDetailSheet = false
    }
    
    @MainActor
    func save() {
        guard transaction != nil else { return }
        
        var newTransaction = transaction
        if categoryField != nil {
            newTransaction?.category = categoryField!
        }
        newTransaction?.amount = Decimal(string: amountField) ?? 0
        newTransaction?.transactionDate = dateField
        newTransaction?.comment = commentField.isEmpty == true ? nil : commentField
        
        isLoading = true
        Task {
            do {
                transaction = try await transactionsService.updateTransaction(newTransaction!)
                isLoading = false
                dismiss()
            } catch {
                errorMessage = "Не удалось обновить категорию"
                isLoading = false
            }
        }
    }
    
    func setTitle(direction: Direction) {
        switch direction {
        case .income:
            title = "Мои доходы"
        case .outcome:
            title = "Мои расходы"
        }
    }
    
    func setFields(_ transaction: Transaction?) {
        guard let transaction = transaction else { return }
        commentField = transaction.comment ?? ""
        dateField = transaction.transactionDate
        amountField = "\(transaction.amount)"
        categoryField = transaction.category
    }
    
    @MainActor
    func fetchCategoriesByDirection(direction: Direction) {
        isLoading = true
        Task {
            do {
                categories = try await categoriesService.fetchCategoriesByDirection(for: direction)
                isLoading = false
            } catch {
                errorMessage = "Не удалось загрузить категории"
                isLoading = false
            }
        }
    }
    
    @MainActor
    func deleteTransaction() {
        guard let transactionId = transaction?.id else { return }
        
        isLoading = true
        Task {
            do {
                try await transactionsService.deleteTransaction(withID: transactionId)
                isLoading = false
                dismiss()
            } catch {
                errorMessage = "Не удалось удалить транзакцию"
                isLoading = false
            }
        }
    }
}
