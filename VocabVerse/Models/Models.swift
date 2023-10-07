import SwiftUI

struct Word: Equatable, Hashable {
    let id: UUID
    let categoryId: UUID
    var nativeWord: String = ""
    var translation: String = ""
    let addedDate: Date
}

struct Category: Equatable {
    let id: UUID
    var name: String = ""
    var words: [Word] = []
    let addedDate: Date
    
    init(
        id: UUID,
        name: String = "",
        words: [Word] = [],
        addedDate: Date
    ) {
        self.id = id
        self.name = name
        self.words = words
        self.addedDate = addedDate
    }
}
