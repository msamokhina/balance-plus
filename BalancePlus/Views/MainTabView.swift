import SwiftUI

struct MainTabView: View {
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
                CategoriesView()
            }
            Tab("Настройки", image: "settings") {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
