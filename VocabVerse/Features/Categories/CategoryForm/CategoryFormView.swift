import SwiftUI
import ComposableArchitecture

struct CategoryFormView: View {
    var store: StoreOf<CategoryFormFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("Category name", text: viewStore.$category.name)
                } header: {
                    Text("Category name")
                }
            }.onChange(of: viewStore.category) { _ in
                viewStore.send(.validateForm)
            }
        }
    }
}

struct CategoryForm_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: CategoryFormFeature.State(
                category: .mock()
            )
        ) {
            CategoryFormFeature()
        }
        
        NavigationStack {
            CategoryFormView(
                store: store
            )
        }
    }
}
