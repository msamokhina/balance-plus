import Foundation

enum Currency: String, Codable, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    
    var id: String { self.rawValue }
    
    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }
    
    var fullName: String {
        switch self {
        case .rub: return "Российский Рубль"
        case .usd: return "Доллар США"
        case .eur: return "Евро"
        }
    }
    
    init(symbol: String) {
        for currency in Currency.allCases {
            if currency.symbol == symbol {
                self = currency
                return
            }
        }
        
        self = Currency.rub
        return
    }
}

struct BankAccount: Codable, Identifiable, ResponseBody {
    let id: Int
    let userId: Int?
    let name: String
    var balance: Decimal
    var currency: Currency
    let createdAt: Date?
    var updatedAt: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)

        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let decodedBalance = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance,
                in: container,
                debugDescription: "Cannot decode balance string to Decimal"
            )
        }
        balance = decodedBalance
        currency = try container.decode(Currency.self, forKey: .currency)
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
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
        } else {
            createdAt = nil
        }

        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
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
        } else {
            updatedAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(String(describing: balance), forKey: .balance)
        try container.encode(currency, forKey: .currency)

        let formatter = ISO8601DateFormatter.withFractionalSeconds

        if let createdAt = createdAt {
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
        if let updatedAt = updatedAt {
            try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        }
    }
    
    init(id: Int, userId: Int?, name: String, balance: Decimal, currency: Currency, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
