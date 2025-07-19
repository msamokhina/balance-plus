import Foundation

@Observable
final class EditTransactionViewModel {
    let transactionsService: TransactionsServiceProtocol
    let categoriesService: CategoriesServiceProtocol
    
    var showingDetailSheet = false
    var showingAlert: Bool = false
    var title = "Редактировать"
    var transaction: Transaction?
    var errorMessage: String?
    var isLoading: Bool = false
    private let balanceConverter: BalanceConverterProtocol
    
    var comment: String = ""
    var amount: String = ""
    var category: Category?
    var date: Date = Date()
    
    var categories: [Category] = []
    
    init(
        transactionsService: TransactionsServiceProtocol,
        categoriesService: CategoriesServiceProtocol
    ) {
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.balanceConverter = BalanceConverter()
    }
    
    @MainActor
    func show(transactionId: Int, direction: Direction) {
        showingDetailSheet = true
        fetchData(transactionId: transactionId, direction: direction)
        setTitle(direction: direction)
    }

    @MainActor
    func fetchData(transactionId: Int, direction: Direction) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedTransaction = try await transactionsService.fetchTransaction(id: transactionId)
                transaction = fetchedTransaction
                categories = try await categoriesService.fetchCategoriesByDirection(for: direction)
   
                self.category = fetchedTransaction.category
                self.amount = balanceConverter.convert(fetchedTransaction.amount)
                self.date = fetchedTransaction.transactionDate
                self.comment = fetchedTransaction.comment ?? ""
                
                self.categories = categories
            } catch {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Произошла непредвиденная ошибка."
                }
                showingAlert = true
            }
        }
        isLoading = false
    }
    
    func dismiss() {
        showingDetailSheet = false
    }
    
    @MainActor
    func save() {
        if category == nil {
            errorMessage = "Заполните все поля"
            showingAlert = true
            return
        }
        
        guard transaction != nil else { return }
        isLoading = true
        errorMessage = nil
        
        var newTransaction = transaction
        
        newTransaction?.category = category!
    
        newTransaction?.amount = balanceConverter.convert(amount)
        newTransaction?.transactionDate = date
        newTransaction?.comment = comment.isEmpty == true ? nil : comment

        Task {
            do {
                transaction = try await transactionsService.updateTransaction(newTransaction!)
                isLoading = false
                dismiss()
            } catch {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Произошла непредвиденная ошибка."
                }
                showingAlert = true
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
    
    @MainActor
    func deleteTransaction() {
        guard let transactionId = transaction?.id else { return }
        
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await transactionsService.deleteTransaction(id: transactionId)
                isLoading = false
                dismiss()
            } catch {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Произошла непредвиденная ошибка."
                }
                showingAlert = true
                isLoading = false
            }
        }
    }
}
