import SwiftUI
import ComposableArchitecture

struct CategoryListView: View {
    let store: StoreOf<CategoryListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            CategoryContentView(store: store)
                .navigationTitle("Vocabulary")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .sheet(
                    store: store.scope(
                        state: \.$addCategory,
                        action: { .addCategory($0) }
                    )
                ) { store in
                    WithViewStore(store, observe: \.isValidForm) { isValid in
                        NavigationStack {
                            CategoryFormView(store: store)
                                .navigationTitle("Add category")
                                .toolbar {
                                    ToolbarItem {
                                        Button(action: {
                                            viewStore.send(
                                                .createCategoryButtonTapped
                                            )
                                        }) {
                                            Text("Add")
                                        }
                                        .disabled(!isValid.state)
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

struct CategoryContentView: View {
    let store: StoreOf<CategoryListFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.categories) { viewStore in
            List {
                Button(action: {
                    viewStore.send(.addCategoryButtonTapped)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Category")
                    }
                }
                .foregroundColor(.blue)
                
                ForEach(viewStore.state, id: \.id) { category in
                    NavigationLink(
                        state: CategoryListFeature.Path.State.wordsList(
                            WordsListFeature.State(
                                words: category.words,
                                categoryId: category.id
                            )
                        )
                    ) {
                        CategoryView(category: category)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewStore.send(.deleteWordsCategoryTapped(category))
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

struct CategoryView: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(category.name)
                .font(.headline)
            
            Text("Number of Words: \(category.words.count)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(10)
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView(
            store: Store(
                initialState: CategoryListFeature.State(
                    categories: [.mock(), .mock()]
                )
            ) {
                CategoryListFeature()
            }
        )
    }
}
