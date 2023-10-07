import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class WordListTests: XCTestCase {
    func testDeleteWord() async {
        let words: [Word] = [
            Word(id: UUID(0), categoryId: UUID(0), nativeWord: "Word", translation: "Translation", addedDate: .distantPast),
            Word(id: UUID(1), categoryId: UUID(0), nativeWord: "Word1", translation: "Translation1", addedDate: .distantPast)
        ]
        let store = TestStore(initialState: WordsListFeature.State(words: words, categoryId: UUID(0))) {
            WordsListFeature()
        } withDependencies: {
            $0.categoryClient = .testValue
        }
        
        let deletedWords: [Word] = [
            Word(id: UUID(1), categoryId: UUID(0), nativeWord: "Word1", translation: "Translation1", addedDate: .distantPast)
        ]
        
        await store.send(.deleteWordButtonTapped(words.first!))
        await store.receive(.wordDeleted(words.first!)) {
            $0.words = deletedWords
        }
    }
    
    func testAddWord() async {
        let store = TestStore(initialState: WordsListFeature.State(categoryId: UUID(0))) {
            WordsListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date = .constant(.distantPast)
            $0.categoryClient = .testValue
        }
        
        var word = Word(id: UUID(0), categoryId: UUID(0), addedDate: .distantPast)
        
        await store.send(.addButtonTapped) {
            $0.addWord = WordFormFeature.State(word: word, formType: .add)
        }
        word.nativeWord = "Native word"
        word.translation = "Translation"
        await store.send(.addWord(.presented(.set(\.$word, word)))) {
            $0.addWord?.word.nativeWord = "Native word"
            $0.addWord?.word.translation = "Translation"
        }
        
        await store.send(.saveWordButtonTaped)
        await store.receive(.wordSaved(word)) {
            $0.addWord = nil
            $0.words = [
                Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "Native word",
                    translation: "Translation",
                    addedDate: .distantPast
                )
            ]
        }
    }
    
    func testEditWord() async {
        var words: [Word] = [
            Word(
                id: UUID(0),
                categoryId: UUID(0),
                nativeWord: "Native word",
                translation: "Translation",
                addedDate: .distantPast
            )
        ]
        let store = TestStore(initialState: WordsListFeature.State(words: words, categoryId: UUID(0))) {
            WordsListFeature()
        } withDependencies: {
            $0.categoryClient = .testValue
        }
        
        
        await store.send(.wordTapped(words[0])) {
            $0.addWord = WordFormFeature.State(word: words[0], formType: .edit)
            $0.addWord?.isValidForm = true
        }
        await store.send(.addWord(.presented(.set(\.$word, words[0]))))
        
        words[0].nativeWord = "New word"
        words[0].translation = "New Translation"
        
        await store.send(.editWordButtonTapped(words[0]))
        await store.receive(.wordEdited(words[0])) {
            $0.addWord = nil
            $0.words = [
                Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "New word",
                    translation: "New Translation",
                    addedDate: .distantPast
                )
            ]
        }
    }
}
