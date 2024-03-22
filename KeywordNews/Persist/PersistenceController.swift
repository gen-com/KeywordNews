//
//  PersistenceController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/23/24.
//

import CoreData

/// 디스크 저장을 관리하는 구현체입니다.
struct PersistenceController: Persistable {
    let container: NSPersistentContainer
    
    // MARK: - Type Property
    
    /// 저장소 이름.
    private static let containerName = "KeywordNews"
    
    // MARK: - Initializer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: PersistenceController.containerName)
        if inMemory, let persistentStoreDescription = container.persistentStoreDescriptions.first {
            persistentStoreDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
