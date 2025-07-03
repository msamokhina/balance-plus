import Foundation

@Observable
final class CategoriesViewModel {
    private var service: CategoriesServiceProtocol
    var categories: [CategoryViewModel] = []
    private let convert: (Category) -> CategoryViewModel = {
        categories in CategoryViewModel(id: categories.id, emoji: String(categories.emoji), name: categories.name)
    }
    
    init(service: CategoriesServiceProtocol) {
        self.service = service
    }
    
    @MainActor
    func loadCategories() {
        Task {
            do {
                let fetchedCategories = try await service.fetchAllCategories()
                categories = fetchedCategories.map(self.convert)
            } catch {
            }
        }
    }
}
