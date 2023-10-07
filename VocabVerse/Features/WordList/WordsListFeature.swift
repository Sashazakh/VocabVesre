import Foundation
import ComposableArchitecture

struct WordsListFeature: Reducer {
    struct State: Equatable {
        @PresentationState var addWord: WordFormFeature.State?
        var words: [Word] = []
        let categoryId: UUID
    }
    enum Action: Equatable {
        case addButtonTapped
        case wordSaved(Word)
        case wordEdited(Word)
        case wordDeleted(Word)
        case addWord(PresentationAction<WordFormFeature.Action>)
        case wordTapped(Word)
        case editWordButtonTapped(Word)
        case deleteWordButtonTapped(Word)
        case saveWordButtonTaped
        case cancelButtonTapped
    }
    
    private enum CancelID {
        case word
    }
    
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.categoryClient) var categoryClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addWord = WordFormFeature.State(
                    word: Word(
                        id: uuid(),
                        categoryId: state.categoryId,
                        addedDate: date()
                    ),
                    formType: .add
                )
                return .none
                
            case .wordSaved(let word):
                state.addWord = nil
                state.words.append(word)
                return .none
                
            case .wordEdited(let editedWord):
                state.addWord = nil
                guard let editedWordIndex = state.words.firstIndex(where: { $0.id == editedWord.id }) else { return .none }
                
                state.words[editedWordIndex] = editedWord
                return .none
                
            case .wordDeleted(let word):
                state.words.removeAll { $0.id == word.id }
                return .none
                
            case .addWord:
                return .none
                
            case .wordTapped(let word):
                state.addWord = WordFormFeature.State(word: word, isValidForm: true, formType: .edit)
                return .none
                
            case .editWordButtonTapped(let editedWord):
                return .run { [categoryId = state.categoryId] send in
                    await categoryClient.editWordInCategory(categoryId, editedWord)
                    await send(.wordEdited(editedWord))
                }
                
            case .deleteWordButtonTapped(let word):
                return .run { [categoryId = state.categoryId] send in
                    await categoryClient.deleteWordInCategory(categoryId, word)
                    await send(.wordDeleted(word))
                }
            
            case .saveWordButtonTaped:
                guard let word = state.addWord?.word else { return .none }
                
                return .run { [categoryId = state.categoryId] send in
                    await categoryClient.addWordToCategory(categoryId, word)
                    await send(.wordSaved(word))
                }
                
            case .cancelButtonTapped:
                state.addWord = nil
                return .none
            }
        }.ifLet(\.$addWord, action: /Action.addWord) {
            WordFormFeature()
        }
    }
}
