import CoreData
import Dependencies

struct CategoryClient {
    var fetchCategories: () async -> [Category]
    var createCategory: (Category) async -> Void
    var addWordToCategory: (UUID, Word) async -> Void
    var editWordInCategory: (UUID, Word) async -> Void
    var deleteWordInCategory: (UUID, Word) async -> Void
    var deleteCategory: (Category) async -> Void
}

extension CategoryClient: DependencyKey {
    
    static var liveValue = CategoryClient {
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "addedDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.relationshipKeyPathsForPrefetching = ["words"]
        
        do {
            let fetchedRequests = try context.fetch(fetchRequest)
            return fetchedRequests.map { categoryEntity in
                var category = Category(entity: categoryEntity)
                category.words.sort { $0.addedDate < $1.addedDate }
                return category
            }
        } catch {
            XCTFail("Can't fetch the category")
            return []
        }
    } createCategory: { category in
        let context = CoreDataManager.shared.container.viewContext
        let newCategory = CategoryEntity(context: context)
        
        newCategory.id = category.id
        newCategory.name = category.name
        newCategory.addedDate = category.addedDate
        
        do {
            context.insert(newCategory)
            try context.save()
        } catch {
            XCTFail("Can't create the category")
        }
    } addWordToCategory: { categoryId, word in
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
        
        do {
            let fetchedEntities = try context.fetch(fetchRequest)
            if let categoryEntity = fetchedEntities.first {
                let wordEntity = WordEntity(context: context)
                wordEntity.id = word.id
                wordEntity.nativeWord = word.nativeWord
                wordEntity.translation = word.translation
                wordEntity.categoryId = word.categoryId
                wordEntity.addedDate = word.addedDate
                categoryEntity.addToWords(wordEntity)
                
                try context.save()
            } else {
                XCTFail("Can't fint category with ID: \(categoryId)")
            }
        } catch {
            XCTFail("Can't delete the category")
        }
    } editWordInCategory: { categoryId, word in
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)

        do {
            let fetchedEntities = try context.fetch(fetchRequest)
            if let categoryEntity = fetchedEntities.first {
                if let wordEntity = categoryEntity.words?.first(where: { ($0 as? WordEntity)?.id == word.id }) as? WordEntity {
                    wordEntity.nativeWord = word.nativeWord
                    wordEntity.translation = word.translation
                    
                    try context.save()
                } else {
                    XCTFail("Can't find word with ID \(word.id) in category with ID \(categoryId)")
                }
            } else {
                XCTFail("Can't find category with ID: \(categoryId)")
            }
        } catch {
            XCTFail("Can't edit the word")
        }
    } deleteWordInCategory: { categoryId, word in
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)

        do {
            let fetchedEntities = try context.fetch(fetchRequest)
            if let categoryEntity = fetchedEntities.first {
                if let wordEntity = categoryEntity.words?.first(where: { ($0 as? WordEntity)?.id == word.id }) as? WordEntity {
                    context.delete(wordEntity)
                    try context.save()
                } else {
                    XCTFail("Can't find word with ID \(word.id) in category with ID \(categoryId)")
                }
            } else {
                XCTFail("Can't find category with ID: \(categoryId)")
            }
        } catch {
            XCTFail("Can't delete the word from the category")
        }
    } deleteCategory: { category in
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        do {
            let fetchedEntities = try context.fetch(fetchRequest)
            if let entity = fetchedEntities.first {
                context.delete(entity)
                try context.save()
            } else {
                XCTFail("Can't find category with ID: \(category.id)")
            }
        } catch {
            XCTFail("Can't delete the category")
        }
    }
    
    static var testValue = CategoryClient {
        return []
    } createCategory: { _ in
    } addWordToCategory: { _, _ in
        return
    } editWordInCategory: { _, _ in
        return
    } deleteWordInCategory: { _, _ in
        return
    } deleteCategory: { _ in
        return
    }
}

extension DependencyValues {
    var categoryClient: CategoryClient {
        get { self[CategoryClient.self] }
        set { self[CategoryClient.self] = newValue }
    }
}

extension Word {
    
    init(entity: WordEntity) {
        self.id = entity.id ?? UUID()
        self.categoryId = entity.categoryId ?? UUID()
        self.nativeWord = entity.nativeWord ?? ""
        self.translation = entity.translation ?? ""
        self.addedDate = entity.addedDate ?? .distantPast
    }
}

extension Category {
    init(entity: CategoryEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        if let words = entity.words, words.count > 0 {
            self.words = words.compactMap { word in
                guard let word = word as? WordEntity else { return nil }
                
                return Word(entity: word)
            }
        } else {
            self.words = []
        }
        self.addedDate = entity.addedDate ?? .distantPast
    }
}
