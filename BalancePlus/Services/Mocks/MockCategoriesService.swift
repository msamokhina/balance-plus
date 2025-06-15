import Foundation

protocol CategoriesServiceProtocol {
    func fetchAllCategories() async throws -> [Category]
    func fetchCategoriesByDirection(for direction: Direction) async throws -> [Category]
}

final class MockCategoriesService: CategoriesServiceProtocol {
    private let mockCategories: [Category] = [
        // Категории доходов
        Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income),
        Category(id: 2, name: "Подарки", emoji: "🎁", direction: .income),
        Category(id: 3, name: "Инвестиции", emoji: "📈", direction: .income),
        Category(id: 4, name: "Возврат долга", emoji: "🤝", direction: .income),

        // Категории расходов
        Category(id: 101, name: "Еда и продукты", emoji: "🍔", direction: .outcome),
        Category(id: 102, name: "Транспорт", emoji: "🚗", direction: .outcome),
        Category(id: 103, name: "Развлечения", emoji: "🎬", direction: .outcome),
        Category(id: 104, name: "Коммунальные услуги", emoji: "💡", direction: .outcome),
        Category(id: 105, name: "Одежда", emoji: "👕", direction: .outcome),
        Category(id: 106, name: "Образование", emoji: "📚", direction: .outcome),
        Category(id: 107, name: "Здоровье", emoji: "💊", direction: .outcome),
        Category(id: 108, name: "Путешествия", emoji: "✈️", direction: .outcome),
        Category(id: 109, name: "Связь", emoji: "📱", direction: .outcome),
        Category(id: 110, name: "Подарки другим", emoji: "🎁", direction: .outcome)
    ]

    func fetchAllCategories() async throws -> [Category] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        return mockCategories
    }

    func fetchCategoriesByDirection(for direction: Direction) async throws -> [Category] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        return mockCategories.filter { $0.direction == direction }
    }
}
