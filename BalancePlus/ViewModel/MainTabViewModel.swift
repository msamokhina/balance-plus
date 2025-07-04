import Foundation

final class MainTabViewModel {
    let categories: CategoriesViewModel

    init(categoriesService: CategoriesServiceProtocol) {
        self.categories = CategoriesViewModel(service: categoriesService)
    }
}
