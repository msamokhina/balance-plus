import SwiftUI

class PopupManager: ObservableObject {
    @Published var showingPopup: Bool = false
    @Published var popupContent: (any View)?

    func showPopup<Content: View>(content: Content) {
        self.popupContent = content
        self.showingPopup = true
    }

    func hidePopup() {
        self.showingPopup = false
        self.popupContent = nil
    }
}

struct MainTabView: View {
    @StateObject var popupManager = PopupManager()
    
    init() {
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
                ZStack {
                    AccountView()
                    if let content = popupManager.popupContent {
                        AnyView(content)
                    }
                }
            }
            Tab("Статьи", image: "categories") {
                CategoriesView()
            }
            Tab("Настройки", image: "settings") {
                SettingsView()
            }
        }
        .environmentObject(popupManager)
    }
}

#Preview {
    MainTabView()
}
