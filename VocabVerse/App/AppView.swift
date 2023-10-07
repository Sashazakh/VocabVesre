import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: \.selectedTabIndex,
                    send: AppFeature.Action.tabChanged
                )
            ) {
                ForEach(AppFeature.State.Tab.allCases) { tab in
                    TabbedView(tab: tab, store: store)
                        .tabItem {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .tag(tab.rawValue)
                }
            }
        }
    }
}

struct TabbedView: View {
    let tab: AppFeature.State.Tab
    let store: StoreOf<AppFeature>
    
    var body: some View {
        switch tab {
        case .learningList:
            NavigationStackStore(
                store.scope(
                    state: \.learningListState.path,
                    action: { .learningList(.path($0)) }
                )) {
                    LearningListView(
                        store: store.scope(
                            state: \.learningListState,
                            action: { .learningList($0) }
                        )
                    ).background(Color.red)
                } destination: { store in
                    switch store {
                    case .flashCards:
                        CaseLet(
                            /LearningListFeature.Path.State.flashCards,
                          action: LearningListFeature.Path.Action.flashCards,
                          then: FlashCardsView.init(store:)
                        )
                    case .correctWriting:
                        CaseLet(
                            /LearningListFeature.Path.State.correctWriting,
                          action: LearningListFeature.Path.Action.correctWriting,
                          then: CorrectWritingView.init(store:)
                        )
                    }
                }
        case .categoryList:
            NavigationStackStore(
                store.scope(
                    state: \.categoryListState.path,
                    action: { .categoryList(.path($0)) }
                )
            ) {
                CategoryListView(
                    store: store.scope(
                        state: \.categoryListState,
                        action: { .categoryList($0) }
                    )
                ).background(Color.red)
            } destination: { store in
                switch store {
                case .wordsList:
                    CaseLet(
                      /CategoryListFeature.Path.State.wordsList,
                      action: CategoryListFeature.Path.Action.wordsList,
                      then: WordsListView.init(store:)
                    )
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        } withDependencies: {
            $0.categoryClient.fetchCategories = {
                return [.mock(), .mock()]
            }
        }
        
        AppView(store: store)
    }
}
