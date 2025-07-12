import Foundation

final class MainTabViewModel {
    let categories: CategoriesViewModel
    let incomeTransactions: TransactionsViewModel
    let outcomeTransactions: TransactionsViewModel
    let editTransaction: EditTransactionViewModel

    init(categoriesService: CategoriesServiceProtocol,
         transactionsService: TransactionsServiceProtocol) {
        self.editTransaction = EditTransactionViewModel(transactionsService: transactionsService, categoriesService: categoriesService)
        
        self.categories = CategoriesViewModel(service: categoriesService)
        self.incomeTransactions = TransactionsViewModel(
            direction: Direction.income,
            service: transactionsService,
            editTransactionViewModel: editTransaction
        )
        self.outcomeTransactions = TransactionsViewModel(
            direction: Direction.outcome,
            service: transactionsService,
            editTransactionViewModel: editTransaction
        )
    }
}
