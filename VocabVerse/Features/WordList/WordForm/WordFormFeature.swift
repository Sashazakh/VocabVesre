import Foundation
import ComposableArchitecture

struct WordFormFeature: Reducer {
    struct State: Equatable {
        @BindingState var word: Word
        var isValidForm: Bool = false
        var formType: FormType
        
        enum FormType {
            case add
            case edit
        }
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
                state.isValidForm = !state.word.nativeWord.isEmpty && !state.word.translation.isEmpty
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}
