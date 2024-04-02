//
//  PersistenceController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/23/24.
//

import CoreData

/// 디스크 저장을 관리하는 구현체입니다.
final class PersistenceController: Persistable {
    let container: NSPersistentContainer
    
    // MARK: - Type Property
    
    /// 저장소 이름.
    private static let containerName = "KeywordNews"
    
    // MARK: - Initializer
    
    /// 디스크 저장을 관리자를 생성합니다.
    /// - Parameter inMemory: 메모리에 저장할 지 여부를 결정합니다.
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
