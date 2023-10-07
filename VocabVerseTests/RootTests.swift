import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class AppTests: XCTestCase {
    func testSelectedLearningTab() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        await store.send(.tabChanged(1)) {
            $0.selectedTab = .categoryList
        }
        
        await store.send(.tabChanged(0)) {
            $0.selectedTab = .learningList
        }
    }
    
    func testAddCategoryHandled() async {
        let category: VocabVerse.Category = Category(
            id: UUID(0),
            words: [
                Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "Native word",
                    translation: "Translation",
                    addedDate: .distantPast
                )
            ],
            addedDate: .distantPast
        )
        
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date = .constant(.distantPast)
        }
        
        await store.send(.categoryList(.categoryCreated(category))) {
            $0.learningListState.categories = [category]
            $0.categoryListState.categories = [category]
        }
    }
    
    func testDeleteCategoryHandled() async {
        let category: VocabVerse.Category = Category(
            id: UUID(0),
            words: [
                Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "Native word",
                    translation: "Translation",
                    addedDate: .distantPast
                )
            ],
            addedDate: .distantPast
        )
        
        let categoryListState = CategoryListFeature.State(categories: [category])
        let learningListState = LearningListFeature.State(categories: [category])
        
        let store = TestStore(initialState: AppFeature.State(
            categoryListState: categoryListState,
            learningListState: learningListState
        )) {
            AppFeature()
        }
        
        await store.send(.categoryList(.categoryDeleted(category))) {
            $0.learningListState.categories = []
            $0.categoryListState.categories = []
        }
    }
    
    func testAddWordInCategoryHandled() async {
        var category: VocabVerse.Category = Category(
            id: UUID(0),
            words: [],
            addedDate: .distantPast
        )
        
        let categoryListState = CategoryListFeature.State(categories: [category])
        let learningListState = LearningListFeature.State(categories: [category])
        
        let store = TestStore(initialState: AppFeature.State(
            categoryListState: categoryListState,
            learningListState: learningListState
        )) {
            AppFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.categoryList(.path(.push(id: 0, state: .wordsList(.init(words: category.words, categoryId: UUID(0)))))))
        
        let word = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Native word",
            translation: "Translation",
            addedDate: .distantPast
        )
        category.words = [word]
        
        await store.send(.categoryList(.path(.element(id: 0, action: .wordsList(.wordSaved(word)))))) {
            $0.categoryListState.categories = [category]
            $0.learningListState.categories = [category]
        }
    }
    
    func testEditWordInCategoryHandled() async {
        var category: VocabVerse.Category = Category(
            id: UUID(0),
            words: [
                Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "Native word",
                    translation: "Translation",
                    addedDate: .distantPast
                )
            ],
            addedDate: .distantPast
        )
        
        let categoryListState = CategoryListFeature.State(categories: [category])
        let learningListState = LearningListFeature.State(categories: [category])
        
        let store = TestStore(initialState: AppFeature.State(
            categoryListState: categoryListState,
            learningListState: learningListState
        )) {
            AppFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.categoryList(.path(.push(id: 0, state: .wordsList(.init(words: category.words, categoryId: UUID(0)))))))
        
        let editedWord = Word(
            id: UUID(0),
            categoryId: UUID(0),
            nativeWord: "Edited Native word",
            translation: "Edited Translation",
            addedDate: .distantPast
        )
        category.words = [editedWord]
        
        await store.send(.categoryList(.path(.element(id: 0, action: .wordsList(.wordEdited(editedWord)))))) {
            $0.categoryListState.categories = [category]
            $0.learningListState.categories = [category]
        }
    }
    
    func testDeleteWordInCategoryHandled() async {
        var category: VocabVerse.Category = Category(
            id: UUID(0),
            words: [
                Word(
                    id: UUID(0),
                    categoryId: UUID(0),
                    nativeWord: "Native word",
                    translation: "Translation",
                    addedDate: .distantPast
                )
            ],
            addedDate: .distantPast
        )
        
        let categoryListState = CategoryListFeature.State(categories: [category])
        let learningListState = LearningListFeature.State(categories: [category])
        
        let store = TestStore(initialState: AppFeature.State(
            categoryListState: categoryListState,
            learningListState: learningListState
        )) {
            AppFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.categoryList(.path(.push(id: 0, state: .wordsList(.init(words: category.words, categoryId: UUID(0)))))))
    
        let deletedWord = category.words[0]
        category.words = []
        
        await store.send(.categoryList(.path(.element(id: 0, action: .wordsList(.wordDeleted(deletedWord)))))) {
            $0.categoryListState.categories = [category]
            $0.learningListState.categories = [category]
        }
    }
}
