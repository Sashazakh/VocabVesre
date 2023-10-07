import XCTest
import ComposableArchitecture
@testable import VocabVerse

@MainActor
final class LearningListTests: XCTestCase {
    func testOnAppearLearningList() async {
        let categories: [VocabVerse.Category] = [
            Category(id: UUID(0), name: "Test category", addedDate: .distantPast)
        ]
        
        let store = TestStore(initialState: LearningListFeature.State()) {
            LearningListFeature()
        } withDependencies: {
            $0.categoryClient.fetchCategories = { categories }
            $0.stateClient = .testValue
        }
        
        await store.send(.onAppear)
        await store.receive(.categoriesFetched(categories)) {
            $0.categories = [Category(id: UUID(0), name: "Test category", addedDate: .distantPast)]
            $0.isCategoriesFecthed = true
        }
    }
    
    func testSelectCategory() async {
        let categories: [VocabVerse.Category] = [
            Category(id: UUID(0), name: "Test category1", addedDate: .distantPast),
            Category(id: UUID(1), name: "Test category2", addedDate: .distantPast)
        ]
        
        let store = TestStore(initialState: LearningListFeature.State(categories: categories)) {
            LearningListFeature()
        }
        
        await store.send(.selectCategoryButtonTapped) {
            $0.categorySelect = CategorySelectFeature.State(categories: categories)
        }
        
        await store.send(.categorySelect(.presented(.selectCategoryTapped(categories[0])))) {
            $0.categorySelect?.selectedCategories = [categories[0].id]
        }
        
        await store.send(.categoriesSelected([categories[0].id])) {
            $0.categorySelect = nil
            $0.categories = categories
            $0.selectedCategories = [categories[0].id]
        }
    }
}
