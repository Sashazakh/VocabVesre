import SwiftUI
import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        var categoryListState = CategoryListFeature.State()
        var learningListState = LearningListFeature.State()
        var selectedTab: Tab = .learningList
        
        var selectedTabIndex: Int {
            self.selectedTab.rawValue
        }
        enum Tab: Int, CaseIterable, Identifiable {
            case learningList
            case categoryList
            
            var id: Int {
                self.rawValue
            }
            
            var title: String {
                switch self {
                case .learningList:
                    return "Learning"
                case .categoryList:
                    return "Vocabulary"
                }
            }
            
            var systemImage: String {
                switch self {
                case .learningList:
                    return "book"
                case .categoryList:
                    return "book.closed"
                }
            }
        }
    }
    enum Action: Equatable {
        case categoryList(CategoryListFeature.Action)
        case learningList(LearningListFeature.Action)
        case tabChanged(Int)
    }
    
    @Dependency(\.stateClient.storeSelectedCategories) var storeSelectedCategories
    
    var body: some ReducerOf<Self> {
        Scope(state: \.categoryListState, action: /Action.categoryList) {
            CategoryListFeature()
        }
        Scope(state: \.learningListState, action: /Action.learningList) {
            LearningListFeature()
        }
        Reduce { state, action in
            switch action {
            case .tabChanged(let tabIndex):
                guard
                    tabIndex != state.selectedTabIndex,
                    let tab = State.Tab(rawValue: tabIndex)
                else { return .none }
                
                state.selectedTab = tab
                return .none
            
            case .categoryList(let action):
                switch action {
                case .categoryCreated(let category):
                    state.learningListState.categories.append(category)
                    return .none
                
                case .categoryDeleted(let category):
                    state.learningListState.categories.removeAll(where: { $0.id == category.id })
                    state.learningListState.selectedCategories.removeAll(where: { $0 == category.id })
                    storeSelectedCategories(state.learningListState.selectedCategories)
                    return .none
                    
                case .path(.element(id: _, action: .wordsList(.wordSaved(let word)))):
                    guard
                        let categoryIndex = state
                            .learningListState
                            .categories
                            .firstIndex(where: { $0.id == word.categoryId })
                    else { return .none }

                    state.learningListState.categories[categoryIndex].words.append(word)
                    return .none
                
                case .path(.element(id: _, action: .wordsList(.wordEdited(let word)))):
                    guard
                        let categoryIndex = state
                            .learningListState
                            .categories
                            .firstIndex(where: { $0.id == word.categoryId }),
                        let wordIndex = state
                            .learningListState
                            .categories[categoryIndex]
                            .words
                            .firstIndex(where: { $0.id == word.id })
                    else { return .none }

                    state.learningListState.categories[categoryIndex].words[wordIndex] = word
                    return .none
                
                case .path(.element(id: _, action: .wordsList(.wordDeleted(let word)))):
                    guard
                        let categoryIndex = state
                            .learningListState
                            .categories
                            .firstIndex(where: { $0.id == word.categoryId })
                    else { return .none }

                    state.learningListState.categories[categoryIndex].words.removeAll(where: { $0.id == word.id })
                    return .none
                    
                default:
                    return .none
                }
                
            case .learningList(_):
                return .none
            }
        }
    }
}
