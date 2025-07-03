import Foundation

@Observable
final class CategoriesViewModel {
    private let service: CategoriesServiceProtocol
    
    var categories: [CategoryViewModel] = []
    var searchText: String = ""
    
    var filteredCategories: [CategoryViewModel] {
        guard !searchText.isEmpty else {
            return categories
        }
        
        return categories.filter { category in
            category.name.lowercased().contains(searchText.lowercased())
        }
    }
    
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
