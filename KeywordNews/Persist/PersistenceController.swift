//
//  PersistenceController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/23/24.
//

import CoreData

final class PersistenceController {
    /// 저장 관리 컨테이너.
    private let container: NSPersistentContainer
    /// 저장 관리 문맥.
    private let context: NSManagedObjectContext
    
    // MARK: - Initializer
    
    /// 디스크 저장을 관리자를 생성합니다.
    /// - Parameter inMemory: 메모리에 저장할 지 여부를 결정합니다.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: Constant.containerName)
        if inMemory, let persistentStoreDescription = container.persistentStoreDescriptions.first {
            persistentStoreDescription.url = URL(fileURLWithPath: Constant.inMemoryPath)
        }
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        context = container.newBackgroundContext()
    }
}

// MARK: - Persistable conformance

extension PersistenceController: Persistable {
    func add(
        _ entityName: String,
        amount: Int,
        with managedObjectHandler: @escaping (NSManagedObject) -> Bool
    ) async throws {
        try await context.perform { [weak self] in
            guard let weakSelf = self else { throw CommonError.valueNotFound }
            let batchInsertRequest = NSBatchInsertRequest(
                entityName: entityName,
                managedObjectHandler: managedObjectHandler
            )
            batchInsertRequest.resultType = .count
            guard let insertResult = try weakSelf.context.execute(batchInsertRequest) as? NSBatchInsertResult,
                  let insertedCount = insertResult.result as? NSInteger
            else { throw Error.failedToAdd(entityName: entityName, failedAmount: amount) }
            guard amount == insertedCount
            else { throw Error.failedToAdd(entityName: entityName, failedAmount: amount - insertedCount) }
        }
    }
    
    func fetch<T>(with request: NSFetchRequest<T>) async throws -> [T] {
        try await context.perform { [weak self] in
            guard let weakSelf = self else { throw CommonError.valueNotFound }
            do { return try weakSelf.context.fetch(request) }
            catch { throw Error.failedToFetch }
        }
    }
    
    func update(
        _ entityName: String,
        forMatching predicate: NSPredicate?, 
        with propertiesToUpdate: [AnyHashable : Any]
    ) async throws {
        try await context.perform { [weak self] in
            guard let weakSelf = self else { throw CommonError.valueNotFound }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.predicate = predicate
            guard let amount = try? weakSelf.context.count(for: fetchRequest) else { throw Error.failedToFetch }
            let batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
            batchUpdateRequest.predicate = predicate
            batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
            batchUpdateRequest.resultType = .updatedObjectsCountResultType
            guard let updatedResult = try weakSelf.context.execute(batchUpdateRequest) as? NSBatchUpdateResult,
                  let updatedCount = updatedResult.result as? Int
            else { throw Error.failedToUpdate(entityName: entityName, failedAmount: amount) }
            guard amount == updatedCount
            else { throw Error.failedToUpdate(entityName: entityName, failedAmount: amount - updatedCount) }
        }
    }
    
    func remove<T>(with request: NSFetchRequest<T>) async throws {
        try await context.perform { [weak self] in
            guard let weakSelf = self else { throw CommonError.valueNotFound }
            guard let fetchRequest = request as? NSFetchRequest<NSFetchRequestResult>
            else { throw Error.failedToRemove }
            fetchRequest.fetchBatchSize = Constant.batchSize
            let removeRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            removeRequest.resultType = .resultTypeStatusOnly
            guard let result = try? weakSelf.context.execute(removeRequest) as? NSBatchDeleteResult,
                  let success = result.result as? Bool, success
            else { throw Error.failedToRemove }
        }
    }
}

// MARK: - Error

extension PersistenceController {
    enum Error: PresentableError {
        /// 데이터를 추가하지 못한 경우.
        case failedToAdd(entityName: String, failedAmount: Int)
        /// 데이터를 가져오지 못한 경우.
        case failedToFetch
        /// 데이터를 수정하지 못한 경우.
        case failedToUpdate(entityName: String, failedAmount: Int)
        /// 데이터를 삭제하지 못한 경우.
        case failedToRemove
        
        var title: String {
            "저장소 오류"
        }
        
        var description: String {
            switch self {
            case let .failedToAdd(entityName, amount):
                return "중복 혹은 다른 이유로 \(amount)개의 \(entityName.lowercased()) 데이터 추가에 실패했습니다."
            case .failedToFetch:
                return "데이터를 가져오는데 실패했습니다."
            case let .failedToUpdate(entityName, amount):
                return "\(amount)개의 \(entityName.lowercased()) 데이터 변경에 실패했습니다."
            case .failedToRemove:
                return "데이터 삭제에 실패했습니다."
            }
        }
    }
}

// MARK: - Contants

extension PersistenceController {
    private enum Constant {
        static let containerName = "KeywordNews"
        static let inMemoryPath = "/dev/null"
        
        static let batchSize = 100
    }
}
