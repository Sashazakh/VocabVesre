import SwiftUI
import ComposableArchitecture

@main
struct VocabVerseApp: App {
    let store: StoreOf<AppFeature>
    
    init() {
        store = Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
