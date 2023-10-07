import Foundation
import ComposableArchitecture

struct CategoryFormFeature: Reducer {
    struct State: Equatable {
        @BindingState var category: Category
        var isValidForm: Bool = false
    }
    enum Action: BindableAction, Equatable {
        case validateForm
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .validateForm:
                state.isValidForm = !state.category.name.isEmpty
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}
