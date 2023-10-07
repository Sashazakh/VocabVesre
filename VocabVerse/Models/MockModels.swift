import Foundation

extension Word {
    
    static func mock(_ categoryId: UUID) -> Self {
        Self(
            id: UUID(),
            categoryId: UUID(),
            nativeWord: "Word",
            translation: "Translation",
            addedDate: .distantPast
        )
    }
}

extension Category {
    
    static func mock() -> Self {
        let id: UUID = UUID()
        
        return Self(
            id: id,
            name: "Category name",
            words: [.mock(id), .mock(id), .mock(id)],
            addedDate: .distantPast
        )
    }
}
