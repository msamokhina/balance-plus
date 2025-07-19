import Foundation

// MARK: csv
extension Transaction {
    init?(csvRow: String) {
        let columns = csvRow.components(separatedBy: ",")
        
        // Ожидаем 8 столбцов
        guard columns.count == 8 else {
            print("Ошибка парсинга CSV: неверное количество столбцов. Ожидалось 8, получено \(columns.count)")
            return nil
        }
        
        // Используем trim для удаления лишних пробелов
        let trim = { (value: String) in value.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let formatter = ISO8601DateFormatter.withFractionalSeconds
        
        // TODO: научиться парсить порядок столбцов из csv
        guard let id = Int(trim(columns[0])),
              let accountId = Int(trim(columns[1])),
              let categoryId = Int(trim(columns[2])),
              let amount = Decimal(string: trim(columns[3])),
              let transactionDate = formatter.date(from: trim(columns[4])),
              let createdAt = formatter.date(from: trim(columns[6])),
              let updatedAt = formatter.date(from: trim(columns[7]))
        else {
            print("Ошибка парсинга CSV: не удалось преобразовать данные в строке: \(csvRow)")
            return nil
        }
        
        let comment = trim(columns[5]).replacingOccurrences(of: "\"", with: "")

        // Создаем заглушки для вложенных объектов
        // TODO: Потом добавим поиск объектов по ID в базе данных
        let account = BankAccount(id: accountId, userId: 0, name: "N/A", balance: 0, currency: .rub, createdAt: Date(), updatedAt: Date())
        let category = Category(id: categoryId, name: "N/A", emoji: "❔", direction: .outcome)

        self.init(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment.isEmpty ? nil : comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    static func parse(csv: String) -> [Transaction] {
        let rows = csv.components(separatedBy: .newlines)
        
        // Пропускаем первую строку, если она является заголовком.
        let dataRows = rows.first?.contains("id,accountId") == true ? Array(rows.dropFirst()) : rows
        
        return dataRows.compactMap { Transaction(csvRow: $0) }
    }
}

// MARK: json
extension Transaction {
    var jsonObject: Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
        
        do {
            let data = try encoder.encode(self)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            }
        } catch {
            print("Ошибка при кодировании Transaction в JSON: \(error)")
        }
        return [:]
    }

    static func parse(jsonObject: Any) -> Transaction? {
        guard let jsonDict = jsonObject as? [String: Any] else {
            print("Ошибка: jsonObject не является словарем [String: Any]")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
            
            return try decoder.decode(Transaction.self, from: data)
        } catch {
            print("Ошибка при парсинге JSON object в Transaction: \(error)")
            return nil
        }
    }
}

struct Transaction: Codable, Identifiable, ResponseBody {
    let id: Int
    let account: BankAccount
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case account
        case category
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)

        account = try container.decode(BankAccount.self, forKey: .account)
        category = try container.decode(Category.self, forKey: .category)
        
        let amountString = try container.decode(String.self, forKey: .amount)
        guard let decodedAmount = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .account,
                in: container,
                debugDescription: "Cannot decode account string to Decimal"
            )
        }
        amount = decodedAmount

        let transactionDateString = try container.decode(String.self, forKey: .transactionDate)
        if let decodedTransactionDate = ISO8601DateFormatter.withFractionalSeconds.date(from: transactionDateString) {
            transactionDate = decodedTransactionDate
        } else if let decodedTransactionDate = ISO8601DateFormatter.withoutFractionalSeconds.date(from: transactionDateString) {
            transactionDate = decodedTransactionDate
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .transactionDate,
                in: container,
                debugDescription: "Cannot decode transactionDate string to Date with ISO8601"
            )
        }
        
        
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let decodedCreatedAt = ISO8601DateFormatter.withFractionalSeconds.date(from: createdAtString) {
            createdAt = decodedCreatedAt
        } else if let decodedCreatedAt = ISO8601DateFormatter.withoutFractionalSeconds.date(from: createdAtString) {
            createdAt = decodedCreatedAt
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Cannot decode createdAt string to Date with ISO8601"
            )
        }
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let decodedUpdatedAt = ISO8601DateFormatter.withFractionalSeconds.date(from: updatedAtString) {
            updatedAt = decodedUpdatedAt
        } else if let decodedUpdatedAt = ISO8601DateFormatter.withoutFractionalSeconds.date(from: updatedAtString) {
            updatedAt = decodedUpdatedAt
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .updatedAt,
                in: container,
                debugDescription: "Cannot decode updatedAt string to Date with ISO8601"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
        try container.encode(id, forKey: .id)
        try container.encode(account, forKey: .account)
        try container.encode(category, forKey: .category)
        try container.encode(String(describing: amount), forKey: .amount)

        let formatter = ISO8601DateFormatter.withFractionalSeconds

        try container.encode(formatter.string(from: transactionDate), forKey: .transactionDate)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
    }
    
    init(id: Int, account: BankAccount, category: Category, amount: Decimal, transactionDate: Date, comment: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct TransactionCreated: Decodable, Identifiable, ResponseBody {
    let id: Int
    let accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)

        accountId = try container.decode(Int.self, forKey: .accountId)
        categoryId = try container.decode(Int.self, forKey: .categoryId)
        
        let amountString = try container.decode(String.self, forKey: .amount)
        guard let decodedAmount = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .accountId,
                in: container,
                debugDescription: "Cannot decode account string to Decimal"
            )
        }
        amount = decodedAmount

        let transactionDateString = try container.decode(String.self, forKey: .transactionDate)
        if let decodedTransactionDate = ISO8601DateFormatter.withFractionalSeconds.date(from: transactionDateString) {
            transactionDate = decodedTransactionDate
        } else if let decodedTransactionDate = ISO8601DateFormatter.withoutFractionalSeconds.date(from: transactionDateString) {
            transactionDate = decodedTransactionDate
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .transactionDate,
                in: container,
                debugDescription: "Cannot decode transactionDate string to Date with ISO8601"
            )
        }
        
        
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let decodedCreatedAt = ISO8601DateFormatter.withFractionalSeconds.date(from: createdAtString) {
            createdAt = decodedCreatedAt
        } else if let decodedCreatedAt = ISO8601DateFormatter.withoutFractionalSeconds.date(from: createdAtString) {
            createdAt = decodedCreatedAt
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Cannot decode createdAt string to Date with ISO8601"
            )
        }
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let decodedUpdatedAt = ISO8601DateFormatter.withFractionalSeconds.date(from: updatedAtString) {
            updatedAt = decodedUpdatedAt
        } else if let decodedUpdatedAt = ISO8601DateFormatter.withoutFractionalSeconds.date(from: updatedAtString) {
            updatedAt = decodedUpdatedAt
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .updatedAt,
                in: container,
                debugDescription: "Cannot decode updatedAt string to Date with ISO8601"
            )
        }
    }
}
