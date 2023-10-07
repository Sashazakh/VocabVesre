import SwiftUI
import ComposableArchitecture

struct WordsListView: View {
    let store: StoreOf<WordsListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            WordsListViewContent(store: store)
                .animation(.easeInOut(duration: 0.2), value: viewStore.state.words)
                .navigationTitle("Word list")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            viewStore.send(.addButtonTapped)
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                .toolbar(.hidden, for: .tabBar)
                .sheet(
                    store: self.store.scope(
                        state: \.$addWord,
                        action: { .addWord($0) }
                    )
                ) { store in
                    WithViewStore(store, observe: { $0 }) { formStore in
                        NavigationStack {
                            WordFormView(store: store)
                                .navigationTitle(
                                    formStore.state.formType == .add ? "Add Word" : "Edit Word"
                                )
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem {
                                        Button(action: {
                                            switch formStore.state.formType {
                                            case .add:
                                                viewStore.send(.saveWordButtonTaped)
                                            case .edit:
                                                viewStore.send(
                                                    .editWordButtonTapped(formStore.state.word)
                                                )
                                            }
                                        }) {
                                            Image(systemName: "square.and.arrow.down")
                                        }
                                        .disabled(!formStore.state.isValidForm)
                                    }
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel") {
                                            viewStore.send(.cancelButtonTapped)
                                        }
                                    }
                                }
                        }
                    }
                }
        }
    }
}

struct WordsListViewContent: View {
    let store: StoreOf<WordsListFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.words) { viewStore in
            if viewStore.state.isEmpty {
                EmptyWordListView(store: store)
            } else {
                List {
                    ForEach(viewStore.state, id: \.id) { word in
                        WordCardView(
                            word: word,
                            onTapAction: {
                                viewStore.send(
                                    .wordTapped(word)
                                )
                            }
                        )
                        .swipeActions() {
                            Button(role: .destructive) {
                                viewStore.send(.deleteWordButtonTapped(word))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EmptyWordListView: View {
    let store: StoreOf<WordsListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("Your word list is empty.")
                    .font(.title)
                    .foregroundColor(.gray)
                Button(action: {
                    viewStore.send(.addButtonTapped)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}


struct Words_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WordsListView(
                store: Store(
                    initialState: WordsListFeature.State(categoryId: UUID())
                ) {
                    WordsListFeature()
                } withDependencies: {
                    $0.categoryClient = .previewValue
                }
            )
        }
    }
}
