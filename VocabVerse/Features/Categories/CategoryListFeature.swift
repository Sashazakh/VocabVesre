import Foundation
import ComposableArchitecture

struct CategoryListFeature: Reducer {
    struct State: Equatable {
        @PresentationState var addCategory: CategoryFormFeature.State?
        var categories: [Category] = []
        var path: StackState<Path.State> = StackState<Path.State>()
        var isCategoriesFetched: Bool = false
    }
    enum Action: Equatable {
        case onAppear
        case categoriesFetched([Category])
        case addCategoryButtonTapped
        case addCategory(PresentationAction<CategoryFormFeature.Action>)
        case createCategoryButtonTapped
        case categoryCreated(Category)
        case deleteWordsCategoryTapped(Category)
        case categoryDeleted(Category)
        case cancelButtonTapped
        case path(StackAction<Path.State, Path.Action>)
    }
    
    struct Path: Reducer {
        enum State: Equatable {
            case wordsList(WordsListFeature.State)
        }
        enum Action: Equatable {
            case wordsList(WordsListFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.wordsList, action: /Action.wordsList) {
                WordsListFeature()
            }
        }
    }

    @Dependency(\.categoryClient) var categoryClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isCategoriesFetched else {
                    return .none
                }
                
                return .run { send in
                    await send(.categoriesFetched(categoryClient.fetchCategories()))
                }
            
            case .categoriesFetched(let categories):
                categories.forEach { print($0) }
                state.categories = categories
                state.isCategoriesFetched = true
                return .none
                
            case .addCategoryButtonTapped:
                state.addCategory = CategoryFormFeature.State(
                    category: Category(id: uuid(), addedDate: date())
                )
                return .none
                
            case .addCategory(_):
                return .none
                
            case .createCategoryButtonTapped:
                guard let category = state.addCategory?.category else { return .none }
                
                return .run { send in
                    await categoryClient.createCategory(category)
                    await send(.categoryCreated(category))
                }
            
            case .categoryCreated(let category):
                state.addCategory = nil
                state.categories.append(category)
                
                return .none
            
            case .deleteWordsCategoryTapped(let category):
                return .run { send in
                    await categoryClient.deleteCategory(category)
                    await send(.categoryDeleted(category))
                }
                
            case .categoryDeleted(let category):
                state.categories.removeAll { $0.id == category.id }
                return .none
                
            case .cancelButtonTapped:
                state.addCategory = nil
                return .none
                
            case .path(.element(id: _, action: .wordsList(.wordSaved(let word)))):
                guard
                    let categoryIndex = state.categories.firstIndex(where: { $0.id == word.categoryId })
                else { return .none}

                state.categories[categoryIndex].words.append(word)
                return .none
            
            case .path(.element(id: _, action: .wordsList(.wordEdited(let word)))):
                guard
                    let categoryIndex = state.categories.firstIndex(where: { $0.id == word.categoryId }),
                    let wordIndex = state.categories[categoryIndex].words.firstIndex(where: { $0.id == word.id })
                else { return .none}

                state.categories[categoryIndex].words[wordIndex] = word
                return .none
            case .path(.element(id: _, action: .wordsList(.wordDeleted(let word)))):
                guard
                    let categoryIndex = state.categories.firstIndex(where: { $0.id == word.categoryId })
                else { return .none}

                state.categories[categoryIndex].words.removeAll(where: { $0.id == word.id })
                return .none
                
            case .path:
                return .none

            }
        }.ifLet(\.$addCategory, action: /Action.addCategory) {
            CategoryFormFeature()
        }.forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
