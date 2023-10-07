import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class CorrectWritingTests: XCTestCase {
    func testHint() async {
        let word: Word = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Native word",
            translation: "Te",
            addedDate: .distantPast
        )
        
        let store = TestStore(initialState: CorrectWritingFeature.State(words: [word])) {
            CorrectWritingFeature()
        }
        
        await store.send(.hintTapped) {
            $0.userInput = "T"
            $0.currentWordState.hintProgress = 1
        }
        await store.send(.hintTapped) {
            $0.userInput = "Te"
            $0.currentWordState.hintProgress = 2
        }
        await store.send(.hintTapped)
    }
    
    func testCorrectTranlation() async {
        let word: Word = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Native word",
            translation: "Translation",
            addedDate: .distantPast
        )
        
        let store = TestStore(
            initialState: CorrectWritingFeature.State(
                words: [word],
                userInput: "Translation"
            )
        ) {
            CorrectWritingFeature()
        }
        
        await store.send(.checkTranslation) {
            $0.currentWordState.isWordCorrect = true
            $0.currentWordState.attempsCount = 1
            $0.correctWordsCount = 1
        }
    }
    
    func testNextWordSwitching() async {
        let word: Word = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Native word",
            translation: "Translation",
            addedDate: .distantPast
        )
        
        let store = TestStore(
            initialState: CorrectWritingFeature.State(
                words: [word],
                userInput: "Translation"
            )
        ) {
            CorrectWritingFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.checkTranslation)
        
        await store.send(.nextWordButtonTapped) {
            $0.userInput = ""
            $0.correctWordsCount = 1
            $0.currentWordIndex = 1
            $0.currentWordState.attempsCount = 0
            $0.currentWordState.isWordCorrect = false
            $0.currentWordState.hintProgress = 0
        }
    }
    
    func testTotalAttempsReached() async {
        let word: Word = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Native word",
            translation: "Translation",
            addedDate: .distantPast
        )
        
        let store = TestStore(
            initialState: CorrectWritingFeature.State(
                words: [word],
                userInput: "Incorrect word"
            )
        ) {
            CorrectWritingFeature()
        }

        store.exhaustivity = .off
        
        await store.send(.checkTranslation)
        await store.send(.checkTranslation)
        await store.send(.checkTranslation) {
            $0.currentWordState.attempsCount = 3
            $0.currentWordState.isWordCorrect = false
            $0.incorrectWordsCount = 1
        }
    }
    
    func testReset() async {
        let word: Word = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Native word",
            translation: "Translation",
            addedDate: .distantPast
        )
        
        let store = TestStore(
            initialState: CorrectWritingFeature.State(
                words: [word],
                currentWordIndex: 1,
                userInput: "Some word",
                currentWordState: .init(attempsCount: 2, isWordCorrect: true)
            )
        ) {
            CorrectWritingFeature()
        }
        
        await store.send(.reset) {
            $0 = CorrectWritingFeature.State(words: [word])
        }
    }
}
