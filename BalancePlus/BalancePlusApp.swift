import SwiftUI

@main
struct BalancePlusApp: App {
    let categoriesService: CategoriesServiceProtocol
    let bankAccountService: BankAccountServiceProtocol
    let transactionsService: TransactionsServiceProtocol

    
    init() {
        let networkClient = NetworkClient(token: "INSERT_TOKEN_HERE")
        self.categoriesService = CategoriesService(networkClient: networkClient)
        self.bankAccountService = BankAccountService(networkClient: networkClient)
        self.transactionsService = TransactionsService(networkClient: networkClient)
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
