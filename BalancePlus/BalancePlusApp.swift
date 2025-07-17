import SwiftUI

@main
struct BalancePlusApp: App {
    let transactionsService: TransactionsServiceProtocol = MockTransactionsService()

    let categoriesService: CategoriesServiceProtocol
    let bankAccountService: BankAccountServiceProtocol

    
    init() {
        let networkClient = NetworkClient(token: "INSERT_TOKEN_HERE")
        self.categoriesService = CategoriesService(networkClient: networkClient)
        self.bankAccountService = BankAccountService(networkClient: networkClient)
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                viewModel: MainTabViewModel(
                    categoriesService: categoriesService,
                    transactionsService: transactionsService,
                    bankAccountService: bankAccountService
                )
            )
        }
    }
    
    
}
