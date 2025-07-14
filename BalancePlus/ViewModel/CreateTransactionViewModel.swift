import Foundation

@Observable
final class CreateTransactionViewModel {
    let transactionsService: TransactionsServiceProtocol
    let categoriesService: CategoriesServiceProtocol
    var showingDetailSheet = false
    var title = "Создать"
    var categories: [Category] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    var showingAlert: Bool = false
    
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
    func show(direction: Direction) {
        errorMessage = nil
        showingDetailSheet = true
        fetchCategoriesByDirection(direction: direction)
        setTitle(direction: direction)
        
        commentField = ""
        amountField = ""
        categoryField = nil
        dateField = Date()
    }

    func dismiss() {
        showingDetailSheet = false
    }
    
    @MainActor
    func create() {
        if amountField.isEmpty || categoryField == nil {
            showingAlert = true
            return
        }
        
        let comment = commentField.isEmpty == true ? nil : commentField
        
        Task {
            do {
                let account = try await MockBankAccountsService().fetchUserBankAccount()
                let transaction: Transaction = Transaction(
                    id: Int(Date().timeIntervalSince1970),
                    account: account,
                    category: categoryField!,
                    amount: Decimal(string: amountField) ?? 0,
                    transactionDate: dateField, comment: comment,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try await transactionsService.createTransaction(transaction)
                
                isLoading = false
                dismiss()
            } catch {
                errorMessage = "Что-то пошло не так"
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
        commentField = ""
        dateField = Date()
        amountField = "0"
        categoryField = nil
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
}
