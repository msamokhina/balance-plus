import SwiftUI

// TODO: сделать попап общим для всех табов и более универсальным, не успела
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
    let viewModel: MainTabViewModel
    @StateObject var popupManager = PopupManager()
    
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
                ZStack {
                    AccountView()
                    if let content = popupManager.popupContent {
                        AnyView(content)
                    }
                }
            }
            Tab("Статьи", image: "categories") {
                CategoriesView(viewModel: viewModel.categories)
            }
            Tab("Настройки", image: "settings") {
                SettingsView()
            }
        }
        .environmentObject(popupManager)
    }
}

#Preview {
    MainTabView(viewModel: .init(categoriesService: MockCategoriesService()))
}
