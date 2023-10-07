import SwiftUI
import ComposableArchitecture

struct CorrectWritingView: View {
    var store: StoreOf<CorrectWritingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.currentWordIndex < viewStore.words.count {
                    if let currentWord = viewStore.currentWord {
                        WordContentView(
                            currentWord: currentWord,
                            store: store
                        )
                    }
                } else {
                    ResultsView(viewStore: viewStore)
                }
            }
            .padding()
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

struct WordContentView: View {
    var currentWord: Word
    var store: StoreOf<CorrectWritingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.currentWordState.isWordCorrect || viewStore.attempsRemaining <= 0 {
                Text("\(currentWord.nativeWord)")
                    .font(.largeTitle)
                    .padding()
                
                
                Text("\(currentWord.translation)")
                    .font(.largeTitle)
                    .padding()
                
                if viewStore.currentWordState.isWordCorrect {
                    Text("Correct! 🎉")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                
                Button("Next Word") {
                    viewStore.send(.nextWordButtonTapped)
                }
                .padding()
                .buttonStyle(.bordered)
                
            } else {
                Text("\(currentWord.nativeWord)")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Enter translation", text: viewStore.$userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Attempts remaining: \(viewStore.attempsRemaining)")
                
                Button("Check") {
                    viewStore.send(.checkTranslation)
                }
                .padding()
                .buttonStyle(.bordered)
                
                Button("Hint") {
                    viewStore.send(.hintTapped)
                }
                .padding()
                .buttonStyle(.bordered)
            }
        }
    }
}

struct ResultsView: View {
    var viewStore: ViewStore<CorrectWritingFeature.State, CorrectWritingFeature.Action>
    
    var body: some View {
        Text("Correct: \(viewStore.correctWordsCount)")
            .font(.title)
        
        Text("Incorrect: \(viewStore.incorrectWordsCount)")
            .font(.title)
        
        Button("Reset") {
            viewStore.send(.reset)
        }
        .frame(width: 100, height: 50)
        .background(Color.blue)
        .cornerRadius(20)
        .foregroundColor(.white)
    }
}

struct CorrectWritingView_Previews: PreviewProvider {
    static var previews: some View {
        CorrectWritingView(store: Store(
            initialState: CorrectWritingFeature.State(words: [.mock(UUID())]),
            reducer: { CorrectWritingFeature() })
        )
    }
}
