import Foundation

extension String {
    func fuzzyMatches(_ query: String) -> Bool {
        let normalizedSelf = self.lowercased()
        let normalizedQuery = query.lowercased()

        guard !normalizedQuery.isEmpty else {
            return true
        }

        var selfIndex = normalizedSelf.startIndex
        var queryIndex = normalizedQuery.startIndex

        while selfIndex < normalizedSelf.endIndex && queryIndex < normalizedQuery.endIndex {
            if normalizedSelf[selfIndex] == normalizedQuery[queryIndex] {
                // Найден символ запроса, переходим к следующему символу запроса
                queryIndex = normalizedQuery.index(after: queryIndex)
            }
            // Всегда переходим к следующему символу в исходной строке
            selfIndex = normalizedSelf.index(after: selfIndex)
        }
        
        return queryIndex == normalizedQuery.endIndex
    }
}
