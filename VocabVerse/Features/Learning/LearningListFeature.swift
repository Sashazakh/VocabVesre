import Foundation
import ComposableArchitecture

struct LearningListFeature: Reducer {
    struct State: Equatable {
        @PresentationState var categorySelect: CategorySelectFeature.State?
        var categories: [Category] = []
        var selectedCategories: [UUID] = []
        var path: StackState<Path.State> = StackState<Path.State>()
        var isCategoriesFecthed: Bool = false
        
        var selectedWords: [Word] {
            categories
                .filter { selectedCategories.contains($0.id) }
                .flatMap { $0.words }
        }

    }
    enum Action: Equatable {
        case onAppear
        case categoriesFetched([Category])
        case selectCategoryButtonTapped
        case categoriesSelected([UUID])
        case categorySelect(PresentationAction<CategorySelectFeature.Action>)
        case path(StackAction<Path.State, Path.Action>)
    }
    struct Path: Reducer {
        enum State: Equatable {
            case flashCards(FlashCardsFeature.State)
            case correctWriting(CorrectWritingFeature.State)
        }
        enum Action: Equatable {
            case flashCards(FlashCardsFeature.Action)
            case correctWriting(CorrectWritingFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.flashCards, action: /Action.flashCards) {
                FlashCardsFeature()
            }
            Scope(state: /State.correctWriting, action: /Action.correctWriting) {
                CorrectWritingFeature()
            }
        }
    }
    
    @Dependency(\.categoryClient.fetchCategories) var fetchCategories
    @Dependency(\.stateClient) var stateClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isCategoriesFecthed else {
                    return .none
                }
    
                state.selectedCategories = stateClient.fetchSelectedCategories()
                return .run { send in
                    await send(.categoriesFetched(fetchCategories()))
                }
               
            case .categoriesFetched(let categories):
                state.categories = categories
                state.isCategoriesFecthed = true
                return .none
                
            case .selectCategoryButtonTapped:
                state.categorySelect = CategorySelectFeature.State(
                    categories: state.categories,
                    selectedCategories: state.selectedCategories
                )
                return .none
                
            case .categoriesSelected(let selectedCategories):
                state.categorySelect = nil
                state.selectedCategories = selectedCategories
                stateClient.storeSelectedCategories(selectedCategories)
                return .none
                
            case .categorySelect(_):
                return .none
                
            case .path(_):
                return .none
            }
        }.ifLet(\.$categorySelect, action: /Action.categorySelect) {
            CategorySelectFeature()
        }.forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
