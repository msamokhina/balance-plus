import SwiftUI

@main
struct BalancePlusApp: App {
    let categoriesService: CategoriesServiceProtocol = MockCategoriesService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                viewModel: MainTabViewModel(
                    categoriesService: categoriesService
                )
            )
        }
    }
}
