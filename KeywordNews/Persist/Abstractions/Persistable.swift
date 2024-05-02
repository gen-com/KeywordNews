//
//  Persistable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/23/24.
//

import CoreData

protocol Persistable {
    /// 데이터를 추가합니다.
    /// - Parameters:
    ///   - entityName: 데이터 타입 이름.
    ///   - managedObjectHandler: 저장할 객체를 처리하는 함수. 저장할 객체를 모두 설정했다면 true를 반환해야 합니다.
    func add(
        _ entityName: String,
        amount: Int,
        with managedObjectHandler: @escaping (NSManagedObject) -> Bool
    ) async throws
    /// 데이터를 찾아서 불러옵니다.
    /// - Parameter request: 찾기 위한 요청.
    /// - Returns: 찾은 데이터.
    func fetch<T: NSManagedObject>(with request: NSFetchRequest<T>) async throws -> [T]
    /// 데이터를 최신화힙니다.
    /// - Parameters:
    ///   - entity: 데이터 타입.
    ///   - predicate: 최신화할 데이터 찾는 조건.
    ///   - propertiesToUpdate: 최신화할 속성 딕셔너리.
    func update(
        _ entityName: String,
        forMatching predicate: NSPredicate?,
        with propertiesToUpdate: [AnyHashable: Any]
    ) async throws
    /// 데이터를 삭제합니다.
    /// - Parameter request: 찾기 위한 요청.
    func remove<T: NSManagedObject>(with request: NSFetchRequest<T>) async throws
}
