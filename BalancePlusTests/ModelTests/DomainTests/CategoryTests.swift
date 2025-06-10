import XCTest
@testable import BalancePlus

final class CategoryTests: XCTestCase {
    // MARK: - init(from decoder: Decoder) Tests
    
    // Валидные данные
    func testCategoryDecoding_Success() throws {
        let jsonString = """
        {
            "id": 1,
            "name": "Зарплата",
            "emoji": "💰",
            "isIncome": true
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Не удалось преобразовать строку JSON в Data")
            return
        }
        XCTAssertNoThrow(try JSONDecoder().decode(Category.self, from: jsonData), "Декодирование не должно выбрасывать ошибку для валидных данных")

        do {
            let category = try JSONDecoder().decode(Category.self, from: jsonData)

            XCTAssertEqual(category.id, 1, "ID категории должен быть 1")
            XCTAssertEqual(category.name, "Зарплата", "Имя категории должно быть 'Зарплата'")
            XCTAssertEqual(category.emoji, "💰", "Эмодзи категории должен быть '💰'")
            XCTAssertEqual(category.direction, .income, "Признак, входящая ли категория, должен быть 'true'")

            print("✅ testCategoryDecoding_Success: Успешно декодирована и проверена категория")

        } catch {
            XCTFail("Декодирование должно быть успешным для валидных данных, но произошла ошибка: \(error)")
        }
    }

    // Отсутствует обязательное поле 'name'.
    // Ожидается ошибка 'keyNotFound'.
    func testCategoryDecoding_MissingName() {
        let jsonString = """
        {
            "id": 2,
            "emoji": "🚗",
            "isIncome": true
        }
        """

        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Не удалось преобразовать строку JSON в Data")
            return
        }

        XCTAssertThrowsError(try JSONDecoder().decode(Category.self, from: jsonData)) { error in
            guard case .keyNotFound(let key, _) = error as? DecodingError else {
                XCTFail("Ожидалась ошибка 'keyNotFound' для поля 'name', но получена другая ошибка: \(error)")
                return
            }
            XCTAssertEqual(key.stringValue, "name", "Ошибка должна быть связана с отсутствующим ключом 'name'")
            print("✅ testCategoryDecoding_MissingName: Ожидаемая ошибка 'keyNotFound' для 'name' получена")
        }
    }

    // В поле 'emoji' более одного символа
    // Ожидается ошибка 'dataCorrupted'
    func testCategoryDecoding_EmojiNotChar() {
        let jsonString = """
        {
            "id": 1,
            "name": "Зарплата",
            "emoji": "💰💰",
            "isIncome": true
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Не удалось преобразовать строку JSON в Data")
            return
        }
        
        XCTAssertThrowsError(try JSONDecoder().decode(Category.self, from: jsonData)) { error in
            guard case .dataCorrupted(let context) = error as? DecodingError else {
                XCTFail("Ожидалась ошибка 'dataCorrupted' для поля 'emoji', но получена другая ошибка: \(error)")
                return
            }
            XCTAssertTrue(context.codingPath.contains(where: { $0.stringValue == "emoji" }),
                          "Ошибка не связана с полем 'emoji' как ожидалось")
            print("✅ testCategoryDecoding_EmojiNotChar: Ожидаемая ошибка 'dataCorrupted' для emoji получена")
        }
    }
}
