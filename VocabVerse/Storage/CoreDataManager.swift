import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(name: "Category")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unable to configure store: \(error), \(error.userInfo)")
            }
        }
        
        viewContext = container.viewContext
        backgroundContext = container.newBackgroundContext()
    }
}
