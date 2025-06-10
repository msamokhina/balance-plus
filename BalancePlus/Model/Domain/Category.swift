import Foundation

enum Direction {
    case income
    case outcome
    
    init(_ isIncome: Bool) {
        self = isIncome ? .income : .outcome
    }
    
    var isIncome: Bool {
        switch self {
        case .income:
            return true
        case .outcome:
            return false
        }
    }
}

extension Category {
    /// Преобразование объекта Category в словарь `[String: Any]`
    var jsonObject: [String: Any] {
        return [
            "id": id,
            "name": name,
            "emoji": String(emoji),
            "isIncome": direction.isIncome
        ]
    }
    
    /// Cоздание объекта Category из словаря `[String: Any]`
    static func parse(jsonObject: Any) -> Category? {
        guard let dictionary = jsonObject as? [String: Any],
              let id = dictionary["id"] as? Int,
              let name = dictionary["name"] as? String,
              let emojiString = dictionary["emoji"] as? String,
              let emoji = emojiString.first,
              let isIncome = dictionary["isIncome"] as? Bool
        else {
            return nil
        }
        
        return Category(
            id: id,
            name: name,
            emoji: emoji,
            direction: Direction(isIncome)
        )
    }
}

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let emojiString = try container.decode(String.self, forKey: .emoji)
        // Гарантируем, что эмодзи — это один символ
        guard let firstChar = emojiString.first, emojiString.count == 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .emoji,
                in: container,
                debugDescription: "Emoji string is not a single character."
            )
        }
        emoji = firstChar
        
        let isIncome = try container.decode(Bool.self, forKey: .isIncome)
        direction = Direction(isIncome)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(String(emoji), forKey: .emoji)
        try container.encode(direction.isIncome, forKey: .isIncome)
    }
    
    init(id: Int, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }
}
