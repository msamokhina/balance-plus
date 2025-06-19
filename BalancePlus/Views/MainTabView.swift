import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Расходы", image: "outcome") {
                OutcomeView()
            }
            Tab("Доходы", image: "income") {
                IncomeView()
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
