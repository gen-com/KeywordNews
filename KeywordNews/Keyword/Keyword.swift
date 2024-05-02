//
//  KeywordInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//
//

import CoreData

final class Keyword: NSManagedObject, KeywordProtocol {
    @NSManaged var value: String
    @NSManaged var order: Int
    
    let isSaved = true
    
    // MARK: - Type Property
    
    /// 엔티티 이름.
    static let entityName = "\(Keyword.self)"
    
    // MARK: - Type method
    
    /// 찾으려는 키워드의 제약 조건을 생성합니다.
    /// - Parameters:
    ///   - key: 키 값.
    ///   - value: 찾으려는 값.
    ///   - Returns: 순서 제약 조건.
    static func predicate(for keyword: KeywordProtocol) -> NSPredicate {
        NSPredicate(format: "%K = %@", #keyPath(Keyword.value), keyword.value)
    }
    
    // MARK: - Fetch request
    
    /// 모든 키워드에 대한 검색 요청을 생성합니다.
    /// - Parameter ascending: 오름차순 정렬 여부. 기본값은 true입니다.
    /// - Returns: 키워드 검색 요청.
    @nonobjc class func fetchRequest(ascending: Bool = true) -> NSFetchRequest<Keyword> {
        let request = NSFetchRequest<Keyword>(entityName: Keyword.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Keyword.order), ascending: ascending)]
        return request
    }
    
    /// 특정 키워드에 대한 검색 요청을 생성합니다.
    /// - Parameter keyword: 찾으려는 키워드.
    /// - Returns: 키워드 검색 요청.
    @nonobjc class func fetchRequest(for keyword: KeywordProtocol) -> NSFetchRequest<Keyword> {
        let request = NSFetchRequest<Keyword>(entityName: Keyword.entityName)
        request.predicate = predicate(for: keyword)
        return request
    }
}
