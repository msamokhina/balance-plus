import SwiftUI

@main
struct BalancePlusApp: App {
    let categoriesService: CategoriesServiceProtocol = MockCategoriesService()
    let transactionsService: TransactionsServiceProtocol = MockTransactionsService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                viewModel: MainTabViewModel(
                    categoriesService: categoriesService,
                    transactionsService: transactionsService
                )
            )
        }
    }
}
