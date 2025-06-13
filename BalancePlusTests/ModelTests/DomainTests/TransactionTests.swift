import XCTest
@testable import BalancePlus

final class TransactionTests: XCTestCase {
    // MARK: - Tests mocks
    
    let mockAccount: BankAccount = {
        let formatter = ISO8601DateFormatter.withFractionalSeconds
        return BankAccount(
            id: 100,
            userId: 1,
            name: "Тестовый счет",
            balance: 5000.00,
            currency: .rub,
            createdAt: formatter.date(from: "2025-06-01T10:00:00.000Z")!,
            updatedAt: formatter.date(from: "2025-06-01T10:00:00.000Z")!
        )
    }()
    
    let mockAccountJSONObject: [String: Any] = [
        "id": 100,
        "userId": 1,
        "name": "Тестовый счет",
        "balance": "5000.00",
        "currency": "RUB",
        "createdAt": "2025-06-01T10:00:00.000Z",
        "updatedAt": "2025-06-01T10:00:00.000Z"
    ]
    
    let mockCategory: BalancePlus.Category = {
        return Category(
            id: 200,
            name: "Тестовая категория",
            emoji: "🧪",
            direction: .outcome
        )
    }()

    let mockCategoryJSONObject: [String: Any] = [
        "id": 200,
        "name": "Тестовая категория",
        "emoji": "🧪",
        "isIncome": false
    ]
    
    let formatter = ISO8601DateFormatter.withFractionalSeconds
    // MARK: - jsonObject Tests
    
    /// Тестирует корректное преобразование полной `Transaction` в `jsonObject`
    func testJSONObject_FullTransaction() {
        let transactionID = 1
        let amount: Decimal = 123.45
        let transactionDate = Date().addingTimeInterval(-1000)
        let comment = "Полная тестовая транзакция"
        let createdAt = Date().addingTimeInterval(-2000)
        let updatedAt = Date()
        let isIncome = false

        let transaction = Transaction(
            id: transactionID,
            account: mockAccount,
            category: mockCategory,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        
        let json = transaction.jsonObject as? [String: Any] // Преобразуем к ожидаемому типу

        // Убеждаемся, что json не nil
        XCTAssertNotNil(json, "jsonObject должен возвращать не-nil словарь")

        // Проверяем обязательные поля
        XCTAssertEqual(json?["id"] as? Int, transactionID, "ID должен совпадать")
        XCTAssertEqual(json?["amount"] as? String, amount.description, "Amount должен быть строкой и совпадать")
        XCTAssertEqual(json?["comment"] as? String, comment, "Comment должен совпадать")

        // Проверяем вложенные объекты
        let accountJson = json?["account"] as? [String: Any]
        XCTAssertNotNil(accountJson, "Account должен быть вложенным словарем")
        XCTAssertEqual(accountJson?["id"] as? Int, mockAccount.id, "ID вложенного аккаунта должен совпадать")
        XCTAssertEqual(accountJson?["name"] as? String, mockAccount.name, "Имя вложенного аккаунта должно совпадать")

        let categoryJson = json?["category"] as? [String: Any]
        XCTAssertNotNil(categoryJson, "Category должен быть вложенным словарем")
        XCTAssertEqual(categoryJson?["id"] as? Int, mockCategory.id, "ID вложенной категории должен совпадать")
        XCTAssertEqual(categoryJson?["name"] as? String, mockCategory.name, "Имя вложенной категории должно совпадать")
        XCTAssertEqual(categoryJson?["isIncome"] as? Bool, isIncome, "Признак входящести вложенной категории должно совпадать")

        // Проверяем даты
        XCTAssertEqual(json?["transactionDate"] as? String, formatter.string(from: transactionDate), "transactionDate должна быть корректно отформатирована")
        XCTAssertEqual(json?["createdAt"] as? String, formatter.string(from: createdAt), "createdAt должна быть корректно отформатирована")
        XCTAssertEqual(json?["updatedAt"] as? String, formatter.string(from: updatedAt), "updatedAt должна быть корректно отформатирована")

        print("✅ testJSONObject_FullTransaction: Успешно преобразована полная транзакция в jsonObject")
    }

    /// Тестирует корректное преобразование `Transaction` с `nil` полем `comment` в `jsonObject`
    func testJSONObject_TransactionWithNilComment() {
        let transactionID = 2
        let amount: Decimal = 500.00
        let transactionDate = Date().addingTimeInterval(-200)
        let createdAt = Date().addingTimeInterval(-300)
        let updatedAt = Date().addingTimeInterval(-100)

        let transaction = Transaction(
            id: transactionID,
            account: mockAccount,
            category: mockCategory,
            amount: amount,
            transactionDate: transactionDate,
            comment: nil, // Comment равен nil
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        let json = transaction.jsonObject as? [String: Any]

        XCTAssertNotNil(json, "jsonObject должен возвращать не-nil словарь")
        XCTAssertEqual(json?["id"] as? Int, transactionID, "ID должен совпадать")
        
        // Проверяем, что поле "comment" отсутствует
        XCTAssertNil(json?["comment"], "Поле 'comment' должно отсутствовать при значении nil")

        print("✅ testJSONObject_TransactionWithNilComment: Успешно преобразована транзакция с nil-комментарием в jsonObject")
    }

    /// Тестирует, что `jsonObject` генерирует правильный тип
    func testJSONObject_ReturnsCorrectType() {
        let transaction = Transaction(
            id: 1,
            account: mockAccount,
            category: mockCategory,
            amount: 100.0,
            transactionDate: Date(),
            comment: "Test",
            createdAt: Date(),
            updatedAt: Date()
        )

        let json = transaction.jsonObject
        XCTAssertTrue(json is [String: Any], "jsonObject должен возвращать тип [String: Any]")
        print("✅ testJSONObject_ReturnsCorrectType: jsonObject возвращает правильный тип")
    }
    
    // MARK: - parse(jsonObject:) Tests
    // MARK: - Тестовый кейс: Успешный парсинг
    
    /// Успешный парсинг `Transaction` из корректного `jsonObject`
    func testParseJSONObject_Success() {
        let now = Date()
        let createdAt = now.addingTimeInterval(-100)
        let updatedAt = now.addingTimeInterval(-50)

        let jsonObject: [String: Any] = [
            "id": 1,
            "account": mockAccountJSONObject,
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": formatter.string(from: now),
            "comment": "Тестовая транзакция",
            "createdAt": formatter.string(from: createdAt),
            "updatedAt": formatter.string(from: updatedAt)
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)

        XCTAssertNotNil(transaction, "Транзакция не должна быть nil при корректных данных")
        XCTAssertEqual(transaction?.id, 1)
        XCTAssertEqual(transaction?.amount, Decimal(string: "123.45"))
        XCTAssertEqual(transaction?.comment, "Тестовая транзакция")
        
        // Проверка вложенных объектов (предполагаем, что Account и Category тоже Codable и их jsonObject/parse работают)
        XCTAssertEqual(transaction?.account.id, 100)
        XCTAssertEqual(transaction?.category.name, "Тестовая категория")
        
        XCTAssertEqual(transaction?.transactionDate, formatter.date(from: jsonObject["transactionDate"] as! String))
        XCTAssertEqual(transaction?.createdAt, formatter.date(from: jsonObject["createdAt"] as! String))
        XCTAssertEqual(transaction?.updatedAt, formatter.date(from: jsonObject["updatedAt"] as! String))

        print("✅ testParseJSONObject_Success: Успешно распарсена транзакция")
    }
    
    // MARK: - Тестовый кейс: Пустое поле 'comment' (nil)

    /// Тестирует, что `parse` корректно обрабатывает отсутствующее поле 'comment'
    func testParseJSONObject_NoComment_Success() {
        let jsonObject: [String: Any] = [
            "id": 1,
            "account": mockAccountJSONObject,
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": formatter.string(from: Date()),
            // "comment" отсутствует
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)

        XCTAssertNotNil(transaction, "Транзакция не должна быть nil при отсутствии 'comment'")
        XCTAssertNil(transaction?.comment, "Поле 'comment' должно быть nil при его отсутствии в JSON")
        print("✅ testParseJSONObject_NoComment_Success: Успешно распарсена транзакция без комментария")
    }

    // MARK: - Тестовый кейс: Некорректный формат `jsonObject`

    /// Тестирует, что `parse` возвращает `nil`, если `jsonObject` не является словарем ([String: Any])
    func testParseJSONObject_NotADictionary_ReturnsNil() {
        let jsonObject: Any = ["invalid_object", 123, true]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil, если jsonObject не является словарем")
        print("✅ testParseJSONObject_NotADictionary_ReturnsNil: Успешно обработан некорректный тип корневого jsonObject")
    }
    
    // MARK: - Тестовые кейсы: Отсутствующие обязательные поля
    
    /// Тестирует, что `parse` возвращает `nil` при отсутствии поля 'id'
    func testParseJSONObject_MissingID_ReturnsNil() {
        var jsonObject: [String: Any] = [
            "userId": 1, // Пример другого поля, которое может быть, но не id
            "account": mockAccountJSONObject,
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": formatter.string(from: Date()),
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]
        jsonObject.removeValue(forKey: "id") // Удаляем обязательное поле

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при отсутствии 'id'")
        print("✅ testParseJSONObject_MissingID_ReturnsNil: Успешно обработано отсутствие 'id'")
    }
    
    /// Тестирует, что `parse` возвращает `nil` при отсутствии поля 'account'
    func testParseJSONObject_MissingAccount_ReturnsNil() {
        let jsonObject: [String: Any] = [
            "id": 1,
            // "account": mockAccountJSONObject, // Отсутствует
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": formatter.string(from: Date()),
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при отсутствии 'account'")
        print("✅ testParseJSONObject_MissingAccount_ReturnsNil: Успешно обработано отсутствие 'account'")
    }
    
    // MARK: - Тестовые кейсы: Некорректные типы данных
    
    /// Тестирует, что `parse` возвращает `nil` при некорректном типе 'id'
    func testParseJSONObject_InvalidIDType_ReturnsNil() {
        let jsonObject: [String: Any] = [
            "id": "1", // String вместо Int
            "account": mockAccountJSONObject,
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": formatter.string(from: Date()),
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при некорректном типе 'id'")
        print("✅ testParseJSONObject_InvalidIDType_ReturnsNil: Успешно обработан некорректный тип 'id'")
    }

    /// Тестирует, что `parse` возвращает `nil` при некорректном формате 'amount'
    func testParseJSONObject_InvalidAmountFormat_ReturnsNil() {
        let jsonObject: [String: Any] = [
            "id": 1,
            "account": mockAccountJSONObject,
            "category": mockCategoryJSONObject,
            "amount": "not_a_decimal", // Некорректный формат Decimal
            "transactionDate": formatter.string(from: Date()),
            "comment": "Тестовая транзакция",
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при некорректном формате 'amount'")
        print("✅ testParseJSONObject_InvalidAmountFormat_ReturnsNil: Успешно обработан некорректный формат 'amount'")
    }

    /// Тестирует, что `parse` возвращает `nil` при некорректном формате даты
    func testParseJSONObject_InvalidDateFormat_ReturnsNil() {
        let jsonObject: [String: Any] = [
            "id": 1,
            "account": mockAccountJSONObject,
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": "invalid-date-string", // Некорректный формат даты
            "comment": "Тестовая транзакция",
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при некорректном формате даты")
        print("✅ testParseJSONObject_InvalidDateFormat_ReturnsNil: Успешно обработан некорректный формат даты")
    }

    // MARK: - Тестовые кейсы: Некорректные вложенные объекты

    /// Тестирует, что `parse` возвращает `nil` при некорректном вложенном 'account'
    func testParseJSONObject_InvalidNestedAccount_ReturnsNil() {
        let invalidAccountJSONObject: [String: Any] = [
            // "id": 2, // Отсутствует id
            "name": "Невалидный счет",
            "balance": "100.00",
            "currency": "USD"
        ]

        let jsonObject: [String: Any] = [
            "id": 1,
            "account": invalidAccountJSONObject, // Некорректный аккаунт
            "category": mockCategoryJSONObject,
            "amount": "123.45",
            "transactionDate": formatter.string(from: Date()),
            "comment": "Тестовая транзакция",
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при некорректном вложенном 'account'")
        print("✅ testParseJSONObject_InvalidNestedAccount_ReturnsNil: Успешно обработан некорректный вложенный 'account'")
    }

    /// Тестирует, что `parse` возвращает `nil` при некорректном вложенном 'category'
    func testParseJSONObject_InvalidNestedCategory_ReturnsNil() {
        let invalidCategoryJSONObject: [String: Any] = [
            "id": 201,
            "name": "Невалидная категория",
            "emoji": "🍕🍔", // Некорректное эмодзи (более одного символа)
            "isIncome": true
        ]

        let jsonObject: [String: Any] = [
            "id": 1,
            "account": mockAccountJSONObject,
            "category": invalidCategoryJSONObject, // Некорректная категория
            "amount": "123.45",
            "transactionDate": formatter.string(from: Date()),
            "comment": "Тестовая транзакция",
            "createdAt": formatter.string(from: Date()),
            "updatedAt": formatter.string(from: Date())
        ]

        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "Транзакция должна быть nil при некорректной вложенной 'category'")
        print("✅ testParseJSONObject_InvalidNestedCategory_ReturnsNil: Успешно обработана некорректная вложенная 'category'")
    }
    
    // MARK: - init?(csvRow: String) Tests
    
    /// Тестирует, что `init` корректно преобразовывает валидную csv строку в `Transaction`
    func testInitFromCSV_Success() {
        let transactionID = 3
        let accountId = 1
        let categoryId = 105
        let amount: Decimal = 3500.00
        let transactionDate = formatter.date(from: "2025-06-01T10:00:00.000Z")
        let comment = "Новая футболка"
        let createdAt = formatter.date(from: "2025-06-01T10:00:00.000Z")
        let updatedAt = formatter.date(from: "2025-06-01T10:00:00.000Z")
        
        let csvRow: String = "3,1,105,3500.00,2025-06-01T10:00:00.000Z,Новая футболка,2025-06-01T10:00:00.000Z,2025-06-01T10:00:00.000Z"
        let transaction: Transaction? = Transaction(csvRow: csvRow)
        
        XCTAssertNotNil(transaction, "Транзакция должна инициализироваться при корректной строке CSV")
        
        XCTAssertEqual(transaction?.id, transactionID, "ID должен совпадать")
        XCTAssertEqual(transaction?.account.id, accountId, "accountId должен совпадать")
        XCTAssertEqual(transaction?.category.id, categoryId, "categoryId должен совпадать")
        XCTAssertEqual(transaction?.amount, amount, "Amount должен совпадать")
        XCTAssertEqual(transaction?.comment, comment, "Comment должен совпадать")

        // Проверяем даты
        XCTAssertEqual(transaction?.transactionDate, transactionDate, "transactionDate должна быть корректно отформатирована")
        XCTAssertEqual(transaction?.createdAt, createdAt, "createdAt должна быть корректно отформатирована")
        XCTAssertEqual(transaction?.updatedAt, updatedAt, "updatedAt должна быть корректно отформатирована")

        print("✅ testInitFromCSV_Success: Успешно обработана валидная строка CSV")
    }

    /// Тестирует, что `init` корректно обрабатывает отсутствующее поле 'comment'
    func testInitFromCSV_Success_NoComment() {
        let csvRow: String = "3,1,105,3500.00,2025-06-01T10:00:00.000Z,,2025-06-01T10:00:00.000Z,2025-06-01T10:00:00.000Z" // Пустой комментарий
        
        let transaction = Transaction(csvRow: csvRow)
        
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction?.comment) // Проверка, что comment стал nil
        print("✅ testInitFromCSV_Success_NoComment: Успешно обработана строка CSV с отсутствующим комментарием")
    }
    
    /// Тестирует, что `init`  возвращает `nil` при недостающем количестве столбцов
    func testInitFromCSV_InvalidColumnCount_ReturnsNil() {
        let csvRow = "1,100,200,50.0,2025-06-01T10:00:00.000Z" // Меньше 8 столбцов
        let transaction = Transaction(csvRow: csvRow)
    
        XCTAssertNil(transaction)
        print("✅ testInitFromCSV_InvalidColumnCount_ReturnsNil: Успешно обработана строка CSV с недостающим количеством столбцов")
    }
}
