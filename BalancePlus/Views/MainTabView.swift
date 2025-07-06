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
                TransactionsListView(direction: .outcome)
            }
            Tab("Доходы", image: "income") {
                TransactionsListView(direction: .income)
            }
            Tab("Счет", image: "account") {
                AccountView()
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
    MainTabView(viewModel: .init(categoriesService: MockCategoriesService()))
}
