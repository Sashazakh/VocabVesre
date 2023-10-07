import Foundation
import ComposableArchitecture

struct FlashCardsFeature: Reducer {
    struct State: Equatable {
        var currentIndex = 0
        var correctWordsScore = 0
        var incorrectWordScore = 0
        var isCurrentCardFlipped: Bool = false
        var words: [Word] = []
        
        var currentWord: Word {
            words[currentIndex]
        }
    }
    enum Action: Equatable {
        case wordsFetched([Word])
        case correctWordTapped
        case incorrectWordTapped
        case cardTapped
        case reset
    }
    
    private enum CancelID {
        case word
    }
    
    @Dependency(\.categoryClient) var categoryClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .wordsFetched(let words):
                state.words = words
                return .none
                
            case .correctWordTapped:
                state.currentIndex += 1
                state.correctWordsScore += 1
                state.isCurrentCardFlipped = false
                return .none
                
            case .incorrectWordTapped:
                state.currentIndex += 1
                state.incorrectWordScore += 1
                state.isCurrentCardFlipped = false
                return .none
                
            case .cardTapped:
                state.isCurrentCardFlipped.toggle()
                return .none
                
            case .reset:
                state = FlashCardsFeature.State(words: state.words)
                return .none
            }
        }
    }
}
