import SwiftUI
import ComposableArchitecture

struct WordFormView: View {
    let store: StoreOf<WordFormFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField(
                        "Native language word",
                        text: viewStore.$word.nativeWord
                    )
                } header: {
                    Text("Native language word")
                }
                Section {
                    TextField(
                        "Translation",
                        text: viewStore.$word.translation
                    )
                } header: {
                    Text("Translation")
                }
            }.onChange(of: viewStore.word) { newValue in
                viewStore.send(.validateForm)
            }
        }
    }
}

struct WordFormView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: WordFormFeature.State(
                word: .mock(UUID()),
                formType: .add
            )
        ) {
            WordFormFeature()
        }
        
        NavigationStack {
            WordFormView(
                store: store
            )
        }
    }
}

