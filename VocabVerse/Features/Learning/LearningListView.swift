import SwiftUI
import ComposableArchitecture

struct LearningListView: View {
    let store: StoreOf<LearningListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Button(action: {
                    viewStore.send(.selectCategoryButtonTapped)
                }) {
                    HStack(alignment: .center) {
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                            .frame(width: 40, height: 40)
                            .alignmentGuide(.leading) { _ in 20 }
                        
                        VStack {
                            Text("Choose category")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .alignmentGuide(.leading) { _ in 0 }
                            
                            Text(
                                "Choosen words: \(viewStore.selectedCategories.count) of \(viewStore.categories.count)"
                            )
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .alignmentGuide(.leading) { _ in 0 }
                            .foregroundColor(.gray)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)
                }
                            
                
                NavigationLink(
                    state: LearningListFeature.Path.State.flashCards(
                        FlashCardsFeature.State(
                            words: viewStore.selectedWords
                        )
                    )
                ) {
                    HStack(alignment: .center) {
                        Image(systemName: "menucard.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                            .frame(width: 40, height: 40)
                            .alignmentGuide(.leading) { _ in 20 }
                        
                        Text("Flash cards")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .alignmentGuide(.leading) { _ in 0 }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)

                }
                
                NavigationLink(
                    state: LearningListFeature.Path.State.correctWriting(
                        CorrectWritingFeature.State(
                            words: viewStore.selectedWords
                        )
                    )
                ) {
                    HStack(alignment: .center) {
                        Image(systemName: "pencil")
                            .foregroundColor(.orange)
                            .imageScale(.large)
                            .frame(width: 40, height: 40)
                            .alignmentGuide(.leading) { _ in 20 }
                        
                        Text("Correct Writing")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .alignmentGuide(.leading) { _ in 0 }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)

                }
            }
            .onAppear {
                self.store.send(.onAppear)
            }
            .sheet(
                store: self.store.scope(
                    state: \.$categorySelect,
                    action: { .categorySelect($0)})
            ) { store in
                WithViewStore(
                    store,
                    observe: \.selectedCategories
                ) { choosenCategories in
                    NavigationStack {
                        CategorySelectView(store: store)
                            .navigationTitle("Choose categories")
                            .toolbar {
                                ToolbarItem() {
                                    Button("Select") {
                                        viewStore.send(
                                            .categoriesSelected(choosenCategories.state)
                                        )
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}

struct LearningList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LearningListView(
                store: Store(
                    initialState: LearningListFeature.State(),
                    reducer: {
                        LearningListFeature()
                    },
                    withDependencies: {
                        $0.categoryClient.fetchCategories = { [.mock(), .mock()] }
                    }
                )
            )
        }
    }
}
