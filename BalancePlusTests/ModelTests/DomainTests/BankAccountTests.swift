import XCTest
@testable import BalancePlus

final class BankAccountTests: XCTestCase {
    // MARK: - init(from decoder: Decoder) Tests
    
    func testBankAccountDecoding_Success() throws {
        let jsonString = """
        {
            "id": 1,
            "userId": 1,
            "name": "Основной счёт",
            "balance": "1000.00",
            "currency": "RUB",
            "createdAt": "2025-06-09T19:58:36.355Z",
            "updatedAt": "2025-06-09T19:58:36.355Z"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Не удалось преобразовать строку JSON в Data")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        XCTAssertNoThrow(try decoder.decode(BankAccount.self, from: jsonData), "Декодирование не должно выбрасывать ошибку для валидных данных")

        do {
            let bankAccount = try decoder.decode(BankAccount.self, from: jsonData)

            XCTAssertEqual(bankAccount.id, 1, "ID счета должен быть 1")
            XCTAssertEqual(bankAccount.userId, 1, "userId счета должен быть 1")
            XCTAssertEqual(bankAccount.name, "Основной счёт", "Имя счета должно быть 'Основной счёт'")
            XCTAssertEqual(bankAccount.balance, Decimal(string: "1000.00"), "Баланс должен быть 1000.00")
            XCTAssertEqual(bankAccount.currency, .rub, "Валюта должна быть RUB")
            
            let formatter = ISO8601DateFormatter.withFractionalSeconds

            guard let expectedCreatedAt = formatter.date(from: "2025-06-09T19:58:36.355Z"),
                  let expectedUpdatedAt = formatter.date(from: "2025-06-09T19:58:36.355Z") else {
                XCTFail("Не удалось создать ожидаемые даты для сравнения")
                return
            }
            
            XCTAssertEqual(bankAccount.createdAt, expectedCreatedAt, "Дата создания должна совпадать")
            XCTAssertEqual(bankAccount.updatedAt, expectedUpdatedAt, "Дата обновления должна совпадать")

            print("✅ testBankAccountDecoding_Success: Успешно декодирован и проверен счет со всеми полями")
        } catch {
            XCTFail("Декодирование должно быть успешным для валидных данных, но произошла ошибка: \(error)")
        }
    }

    // В поле 'currency' переданно значение не из enum 'Currency'
    // Ожидается ошибка 'dataCorrupted'
    func testBankAccountDecoding_CurrencyNotInEnum() {
        let jsonString = """
        {
            "id": 2,
            "userId": 1,
            "name": "Счёт в шекелях",
            "balance": "500.00",
            "currency": "ILS",
            "createdAt": "2025-06-09T19:58:36.355Z",
            "updatedAt": "2025-06-09T19:58:36.355Z"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Не удалось преобразовать строку JSON в Data")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601withFractionalSeconds

        XCTAssertThrowsError(try decoder.decode(BankAccount.self, from: jsonData)) { error in
            guard case .dataCorrupted(let context) = error as? DecodingError else {
                XCTFail("Ожидалась ошибка 'dataCorrupted' для поля 'currency', но получена другая ошибка: \(error)")
                return
            }
            
            XCTAssertTrue(context.codingPath.contains(where: { $0.stringValue == "currency" }),
                          "Ошибка не связана с полем 'currency' как ожидалось")
            print("✅ testBankAccountDecoding_CurrencyNotInEnum: Ожидаемая ошибка 'dataCorrupted' для невалидной валюты получена и проверена")
        }
    }
}
