import Foundation
import ComposableArchitecture

struct CorrectWritingFeature: Reducer {
    struct State: Equatable {
        let words: [Word]
        let attemptsAvailable: Int = 3
        var currentWordIndex: Int = 0
        var correctWordsCount: Int = 0
        var incorrectWordsCount: Int = 0
        @BindingState var userInput: String = ""
        var currentWordState: CurrentWordState = CurrentWordState()
        
        struct CurrentWordState: Equatable {
            var attempsCount: Int = 0
            var isWordCorrect: Bool = false
            var hintProgress: Int = 0
        }
            
        var currentWord: Word? {
            guard currentWordIndex < words.count else {
                return nil
            }
            
            return words[currentWordIndex]
        }
        var attempsRemaining: Int {
            attemptsAvailable - currentWordState.attempsCount
        }
    }
    enum Action: BindableAction, Equatable {
        case checkTranslation
        case nextWordButtonTapped
        case hintTapped
        case reset
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .checkTranslation:
                guard let currentWord = state.currentWord else { return .none }
                
                let isWordCorrect = state.userInput == currentWord.translation
                state.currentWordState.isWordCorrect = isWordCorrect
                state.currentWordState.attempsCount += 1
                state.correctWordsCount += isWordCorrect ? 1 : 0
                state.incorrectWordsCount += state.attempsRemaining == 0 && !isWordCorrect ? 1 : 0
                return .none
            
            case .nextWordButtonTapped:
                state.currentWordState = State.CurrentWordState()
                state.userInput = ""
                state.currentWordIndex += 1
                return .none
            
            case .hintTapped:
                if let currentWord = state.currentWord,
                   state.currentWordState.hintProgress < currentWord.translation.count {
                    if !currentWord.translation.hasPrefix(state.userInput) {
                        state.userInput = ""
                    }
                    let nextIndex = currentWord.translation.index(
                        currentWord.translation.startIndex,
                        offsetBy: state.currentWordState.hintProgress
                    )
                    let nextLetter = currentWord.translation[nextIndex]
                    state.userInput += String(nextLetter)
                    state.currentWordState.hintProgress += 1
                    
                    return .none
                }
                return .none
            
            case .reset:
                state = State(words: state.words)
                return .none
            
            case .binding(_):
                return .none
            }
        }
    }
}
