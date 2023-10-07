import Foundation
import ComposableArchitecture

struct CategorySelectFeature: Reducer {
    struct State: Equatable {
        var categories: [Category] = []
        var selectedCategories: [UUID] = []
    }
    enum Action: Equatable {
        case selectCategoryTapped(Category)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectCategoryTapped(let category):
                if state.selectedCategories.contains(category.id) {
                    state.selectedCategories.removeAll(where: { $0 == category.id })
                } else {
                    state.selectedCategories.append(category.id)
                }
                return .none
            }
        }
    }
}
