import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class LearningTests: XCTestCase {
    func testCardFlipped() async {
        let words: [Word] = [
            Word(id: UUID(0), categoryId: UUID(0), nativeWord: "Native", translation: "Translation", addedDate: .distantPast)
        ]
        
        let store = TestStore(initialState: FlashCardsFeature.State(words: words)) {
            FlashCardsFeature()
        }
        
        await store.send(.cardTapped) {
            $0.isCurrentCardFlipped = true
        }
        
    }
    
    func testWordsLearningProccess() async {
        let words: [Word] = [
            Word(id: UUID(0), categoryId: UUID(0), nativeWord: "Native", translation: "Translation", addedDate: .distantPast),
            Word(id: UUID(1), categoryId: UUID(0), nativeWord: "Native", translation: "Translation", addedDate: .distantPast),
            Word(id: UUID(2), categoryId: UUID(0), nativeWord: "Native", translation: "Translation", addedDate: .distantPast)
        ]

        let store = TestStore(initialState: FlashCardsFeature.State(words: words)) {
            FlashCardsFeature()
        } withDependencies: {
            $0.categoryClient = .testValue
        }

        await store.send(.correctWordTapped) {
            $0.correctWordsScore = 1
            $0.currentIndex = 1
        }
        
        await store.send(.incorrectWordTapped) {
            $0.incorrectWordScore = 1
            $0.correctWordsScore = 1
            $0.currentIndex = 2
        }
        
        await store.send(.correctWordTapped) {
            $0.correctWordsScore = 2
            $0.incorrectWordScore = 1
            $0.currentIndex = 3
        }
        
        await store.send(.reset) {
            $0.correctWordsScore = 0
            $0.incorrectWordScore = 0
            $0.currentIndex = 0
        }
    }
}
