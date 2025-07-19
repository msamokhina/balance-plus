import SwiftUI

struct MainTabView: View {
    let viewModel: MainTabViewModel
    
    init(viewModel: MainTabViewModel) {
        self.viewModel = viewModel
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            Tab("Расходы", image: "outcome") {
                TransactionsListView(viewModel: viewModel.outcomeTransactions)
            }
            Tab("Доходы", image: "income") {
                TransactionsListView(viewModel: viewModel.incomeTransactions)
            }
            Tab("Счет", image: "account") {
                AccountView(viewModel: viewModel.account)
            }
            Tab("Статьи", image: "categories") {
                CategoriesView(viewModel: viewModel.categories)
            }
            Tab("Настройки", image: "settings") {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainTabView(viewModel: .init(categoriesService: MockCategoriesService(), transactionsService: MockTransactionsService(), bankAccountService: MockBankAccountsService()))
}
