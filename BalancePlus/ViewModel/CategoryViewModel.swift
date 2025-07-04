import Foundation

final class CategoryViewModel: Identifiable {
    let id: Int
    let emoji: String
    let name: String
    
    init(id: Int, emoji: String, name: String) {
        self.id = id
        self.emoji = emoji
        self.name = name
    }
}
