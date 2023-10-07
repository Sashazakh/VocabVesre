import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class WordFormTests: XCTestCase {
    func testIsValidForm() async {
        let store = TestStore(
            initialState: WordFormFeature.State(
                word: Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "Test",
                    translation: "Translation",
                    addedDate: .distantPast
                ),
                formType: .add
            )
        ) {
            WordFormFeature()
        }
        
        await store.send(.validateForm) {
            $0.isValidForm = true
        }
    }
    
    func testUnvalidForm() async {
        let store = TestStore(
            initialState: WordFormFeature.State(
                word: Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "",
                    translation: "",
                    addedDate: .distantPast
                ),
                formType: .add
            )
        ) {
            WordFormFeature()
        }
        
        await store.send(.validateForm)
    }
}
