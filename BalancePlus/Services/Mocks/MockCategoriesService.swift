import Foundation

/// Протокол, определяющий интерфейс для работы с категориями
protocol CategoriesServiceProtocol {
    /// Получает все категории
    /// - Returns: Массив объектов `Category`
    /// - Throws: Ошибки, связанные с получением данных
    func fetchAllCategories() async throws -> [Category]

    /// Получает список категорий определённого направления (доход или расход)
    /// - Parameter direction: Направление категории (`.income` или `.outcome`)
    /// - Returns: Массив объектов `Category`, соответствующих заданному направлению
    /// - Throws: Ошибки, связанные с получением данных.
    func fetchCategoriesByDirection(for direction: Direction) async throws -> [Category]
}

/// Мок сервиса категорий
/// Педоставляет заранее определенный набор категорий
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

    /// Имитирует асинхронное получение всех категорий
    /// Добавляет небольшую задержку для имитации сетевого запроса
    func fetchAllCategories() async throws -> [Category] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        return mockCategories
    }

    /// Имитирует асинхронное получение категорий по направлению (доход/расход)
    /// Добавляет небольшую задержку для имитации сетевого запроса
    /// - Parameter direction: Направление, по которому нужно отфильтровать категории
    func fetchCategoriesByDirection(for direction: Direction) async throws -> [Category] {
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        return mockCategories.filter { $0.direction == direction }
    }
}
