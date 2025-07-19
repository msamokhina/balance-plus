import Foundation

final class MainTabViewModel {
    let categories: CategoriesViewModel
    let account: AccountViewModel
    let incomeTransactions: TransactionsViewModel
    let outcomeTransactions: TransactionsViewModel
    
    init(categoriesService: CategoriesServiceProtocol,
         transactionsService: TransactionsServiceProtocol,
         bankAccountService: BankAccountServiceProtocol
    ) {
        self.categories = CategoriesViewModel(service: categoriesService)
        self.account = AccountViewModel(
            state: .processing(AccountViewModel.ProcessingViewModel(reason: .loading)),
            service: bankAccountService)
        
        let editTransactionViewModel = EditTransactionViewModel(
            transactionsService: transactionsService,
            categoriesService: categoriesService
        )
        let createTransactionViewModel = CreateTransactionViewModel(
            transactionsService: transactionsService,
            categoriesService: categoriesService,
            bankAccountService: bankAccountService
        )
        
        self.incomeTransactions = TransactionsViewModel(
            direction: Direction.income,
            service: transactionsService,
            accountService: bankAccountService,
            editTransactionViewModel: editTransactionViewModel,
            createTransactionViewModel: createTransactionViewModel,
            
            historyViewModel: HistoryViewModel(
                state: .processing(HistoryViewModel.ProcessingViewModel(reason: .loading)),
                direction: Direction.income,
                selectedStartDate: Date().startOfDayMonthAgo(),
                selectedEndDate: Date().endOfDay(),
                transactionsService: transactionsService,
                accountService: bankAccountService,
                editTransactionViewModel: editTransactionViewModel
            )
        )
        self.outcomeTransactions = TransactionsViewModel(
            direction: Direction.outcome,
            service: transactionsService,
            accountService: bankAccountService,
            editTransactionViewModel: editTransactionViewModel,
            createTransactionViewModel: createTransactionViewModel,
            
            historyViewModel: HistoryViewModel(
                state: .processing(HistoryViewModel.ProcessingViewModel(reason: .loading)),
                direction: Direction.outcome,
                selectedStartDate: Date().startOfDayMonthAgo(),
                selectedEndDate: Date().endOfDay(),
                transactionsService: transactionsService,
                accountService: bankAccountService,
                editTransactionViewModel: editTransactionViewModel
            )
        )
    }
}
