import Foundation

final class MainTabViewModel {
    let categories: CategoriesViewModel
    let account: AccountViewModel
    let incomeTransactions: TransactionsViewModel
    let outcomeTransactions: TransactionsViewModel
    let editTransaction: EditTransactionViewModel
    let createTransaction: CreateTransactionViewModel
    
    init(categoriesService: CategoriesServiceProtocol,
         transactionsService: TransactionsServiceProtocol,
         bankAccountService: BankAccountServiceProtocol
    ) {
        self.editTransaction = EditTransactionViewModel(transactionsService: transactionsService, categoriesService: categoriesService)
        self.createTransaction = CreateTransactionViewModel(transactionsService: transactionsService, categoriesService: categoriesService)
        
        self.categories = CategoriesViewModel(service: categoriesService)
        self.account = AccountViewModel(
            state: .processing(AccountViewModel.ProcessingViewModel(reason: .loading)),
            service: bankAccountService)
        
        self.incomeTransactions = TransactionsViewModel(
            direction: Direction.income,
            service: transactionsService,
            editTransactionViewModel: editTransaction,
            createTransactionViewModel: createTransaction
        )
        self.outcomeTransactions = TransactionsViewModel(
            direction: Direction.outcome,
            service: transactionsService,
            editTransactionViewModel: editTransaction,
            createTransactionViewModel: createTransaction
        )
    }
}
