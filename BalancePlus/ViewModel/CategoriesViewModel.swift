import Foundation

final class CategoriesViewModel {
    private var service: CategoriesServiceProtocol
    
    init(service: CategoriesServiceProtocol) {
        self.service = service
    }
}
