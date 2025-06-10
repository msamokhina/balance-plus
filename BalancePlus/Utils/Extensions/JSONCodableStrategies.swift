import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formatter = ISO8601DateFormatter.withFractionalSeconds

        if let date = formatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractionalSeconds = custom { date, encoder in
        let formatter = ISO8601DateFormatter.withFractionalSeconds

        let dateString = formatter.string(from: date)
        var container = encoder.singleValueContainer()
        try container.encode(dateString)
    }
}
