import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Расходы", image: "outcome") {
                OutcomeView().background(Color("BackgroundColor"))
            }
            Tab("Доходы", image: "income") {
                IncomeView().background(Color("BackgroundColor"))
            }
            Tab("Счет", image: "account") {
                AccountView().background(Color("BackgroundColor"))
            }
            Tab("Статьи", image: "categories") {
                CategoriesView().background(Color("BackgroundColor"))
            }
            Tab("Настройки", image: "settings") {
                SettingsView().background(Color("BackgroundColor"))
            }
        }
    }
}

#Preview {
    MainTabView()
}
