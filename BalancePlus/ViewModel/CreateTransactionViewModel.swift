import Foundation

@Observable
final class CreateTransactionViewModel {
    let transactionsService: TransactionsServiceProtocol
    let categoriesService: CategoriesServiceProtocol
    let bankAccountService: BankAccountServiceProtocol
    
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
         categoriesService: CategoriesServiceProtocol,
         bankAccountService: BankAccountServiceProtocol
    ) {
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.bankAccountService = bankAccountService
    }
    
    @MainActor
    func show(direction: Direction) {
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
            errorMessage = "Заполните все поля"
            showingAlert = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let comment = commentField.isEmpty == true ? "" : commentField
        
        Task {
            do {
                let account = try await bankAccountService.fetchUserBankAccount()
                
                _ = try await transactionsService.createTransaction(accountId: account.id, categoryId: categoryField!.id, amount: amountField, transactionDate: dateField, comment: comment)
                
                isLoading = false
                dismiss()
            } catch {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Не удалось создать транзакцию"
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
    func fetchCategoriesByDirection(direction: Direction) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                categories = try await categoriesService.fetchCategoriesByDirection(for: direction)
                isLoading = false
            } catch {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Не удалось загрузить категории"
                }
                showingAlert = true
                isLoading = false
            }
        }
    }
}
