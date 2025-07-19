import Foundation

@Observable
final class CategoriesViewModel {
    private let service: CategoriesServiceProtocol
    
    var categories: [CategoryViewModel] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showingAlert: Bool = false

    var filteredCategories: [CategoryViewModel] {
        guard !searchText.isEmpty else {
            return categories
        }
        
        return categories.filter { $0.name.fuzzyMatches(searchText) }
    }
    
    private let convert: (Category) -> CategoryViewModel = {
        categories in CategoryViewModel(id: categories.id, emoji: String(categories.emoji), name: categories.name)
    }
    
    init(service: CategoriesServiceProtocol) {
        self.service = service
    }
    
    @MainActor
    func loadCategories() {
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            do {
                let fetchedCategories = try await service.fetchAllCategories()
                categories = fetchedCategories.map(self.convert)
                isLoading = false
            } catch {
                if let networkError = error as? NetworkError {
                    self.errorMessage = networkError.localizedDescription
                } else {
                    self.errorMessage = "Произошла непредвиденная ошибка."
                }
                showingAlert = true
                isLoading = false
            }
        }
    }
}
