import Dependencies
import Foundation

struct StateClient {
    var storeSelectedCategories: ([UUID]) -> ()
    var fetchSelectedCategories: () -> [UUID]
}

extension StateClient: DependencyKey {
    
    static var liveValue = StateClient { ids in
        UserDefaults.standard.set(ids.map { $0.uuidString }, forKey: "selectedCategories")
    } fetchSelectedCategories: {
        if let ids = UserDefaults.standard.array(forKey: "selectedCategories") as? [String] {
            return ids.compactMap { UUID(uuidString: $0) }
        } else {
            return []
        }
    }
    
    static var testValue = StateClient { _ in
    } fetchSelectedCategories: {
        return []
    }
}

extension DependencyValues {
    var stateClient: StateClient {
        get { self[StateClient.self] }
        set { self[StateClient.self] = newValue }
    }
}
