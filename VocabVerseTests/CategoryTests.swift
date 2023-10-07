import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class CategoryTests: XCTestCase {
    func testOnAppearCategories() async {
        let categories: [VocabVerse.Category] = [
            Category(id: UUID(0), name: "Test category", addedDate: .distantPast)
        ]
        
        let store = TestStore(initialState: CategoryListFeature.State()) {
            CategoryListFeature()
        } withDependencies: {
            $0.categoryClient.fetchCategories = {
                categories
            }
        }
        
        await store.send(.onAppear)
        await store.receive(.categoriesFetched(categories)) {
            $0.categories = categories
            $0.isCategoriesFetched = true
        }
    }
    
    func testDeleteCategory() async {
        let store = TestStore(initialState: CategoryListFeature.State(categories: [
            Category(id: UUID(0), name: "Test category 1", addedDate: .distantPast),
            Category(id: UUID(1), name: "Test category 2", addedDate: .distantPast)
        ])) {
            CategoryListFeature()
        } withDependencies: {
            $0.categoryClient = .testValue
        }
        
        await store.send(
            .deleteWordsCategoryTapped(
                Category(
                    id: UUID(1),
                    name: "Test category 2",
                    addedDate: .distantPast
                )
            )
        )
        await store.receive(.categoryDeleted(Category(id: UUID(1), name: "Test category 2", addedDate: .distantPast))) {
            $0.categories = [Category(id: UUID(0), name: "Test category 1", addedDate: .distantPast)]
        }
    }

    func testAddCategory() async {
        let store = TestStore(initialState: CategoryListFeature.State()) {
            CategoryListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date = .constant(.distantPast)
            $0.categoryClient = .testValue
        }

        var category = Category(id: UUID(0), addedDate: .distantPast)

        await store.send(.addCategoryButtonTapped) {
            $0.addCategory = CategoryFormFeature.State(category: category)
        }
        
        category.name = "Test category"
        await store.send(.addCategory(.presented(.set(\.$category, category)))) {
            $0.addCategory?.category.name = "Test category"
        }
        
        await store.send(.createCategoryButtonTapped)
        await store.receive(.categoryCreated(category)) {
            $0.addCategory = nil
            $0.categories = [Category(id: UUID(0), name: "Test category", addedDate: .distantPast)]
        }
    }
    
    func testAddWordToCategory() async {
        var word = Word(id: UUID(0), categoryId: UUID(0), addedDate: .distantPast)
        let category = Category(id: UUID(0), addedDate: .distantPast)
        let store = TestStore(initialState: CategoryListFeature.State(categories: [category])) {
            CategoryListFeature()
        } withDependencies: {
            $0.date = .constant(.distantPast)
            $0.uuid = .incrementing
            $0.categoryClient = .testValue
        }
        
        await store.send(.path(.push(id: 0, state: .wordsList(WordsListFeature.State(categoryId: UUID(0)))))) {
            $0.path[id: 0] = .wordsList(WordsListFeature.State(categoryId: UUID(0)))
        }
        
        await store.send(.path(.element(id: 0, action: .wordsList(.addButtonTapped)))) {
            $0.path[id: 0] = .wordsList(WordsListFeature.State(
                addWord: WordFormFeature.State(word: word, formType: .add),
                categoryId: UUID(0)
            ))
        }
        word.nativeWord = "Native word"
        word.translation = "Translation"
        
        await store.send(.path(.element(id: 0, action: .wordsList(.addWord(.presented(.set(\.$word, word))))))) {
            $0.path[id: 0] = .wordsList(
                WordsListFeature.State(
                    addWord: WordFormFeature.State(
                        word: Word(
                            id: UUID(0),
                            categoryId: UUID(0),
                            nativeWord: "Native word",
                            translation: "Translation",
                            addedDate: .distantPast
                        ),
                        formType: .add
                    ),
                    categoryId: UUID(0)
                )
            )
        }
        
        await store.send(.path(.element(id: 0, action: .wordsList(.saveWordButtonTaped))))
        await store.receive(.path(.element(id: 0, action: .wordsList(.wordSaved(word))))) {
            $0.path[id: 0] = .wordsList(
                WordsListFeature.State(
                    addWord: nil,
                    words: [
                        Word(
                            id: UUID(0),
                            categoryId: UUID(0),
                            nativeWord: "Native word",
                            translation: "Translation",
                            addedDate: .distantPast
                        )
                    ],
                    categoryId: UUID(0)
                )
            )
            $0.categories = [
                Category(
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
            ]
        }
    }
}
