import SwiftUI
import ComposableArchitecture

struct CategorySelectView: View {
    let store: StoreOf<CategorySelectFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.categories, id: \.id) { wordCategory in
                HStack {
                    Text(wordCategory.name)
                    Spacer()
                    if viewStore.state.selectedCategories.contains(wordCategory.id) {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "square")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewStore.send(.selectCategoryTapped(wordCategory))
                }
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectView(
            store: Store(
                initialState: CategorySelectFeature.State(
                    categories: [.mock(), .mock(), .mock()]
                ),
                reducer: {
                    CategorySelectFeature()
                }
            )
        )
    }
}
