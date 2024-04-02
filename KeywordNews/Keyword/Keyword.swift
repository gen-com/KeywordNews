//
//  KeywordInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//
//

import CoreData

/// 코어 데이터 기반으로 구현된 키워드입니다.
final class Keyword: NSManagedObject, KeywordProtocol {
    @NSManaged var value: String
    @NSManaged var order: Int
    
    let isSaved = true
    
    // MARK: - Type Property
    
    /// 엔티티 이름.
    static let entityName = "\(Keyword.self)"
    
    // MARK: - Fetch request
    
    /// 모든 키워드에 대한 검색 요청을 생성합니다.
    /// - Parameter ascending: 오름차순 정렬 여부.
    /// - Returns: 키워드 검색 요청.
    @nonobjc class func fetchRequest(ascending: Bool = true) -> NSFetchRequest<Keyword> {
        let request = NSFetchRequest<Keyword>(entityName: Keyword.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: ascending)]
        return request
    }
    
    /// 특정 순서보다 나중의 키워드에 대한 검색 요청을 생성합니다.
    /// - Parameters:
    ///   - startIndex: 기준이 되는 순서.
    ///   - ascending: 오름차순 정렬 여부.
    /// - Returns: 키워드 검색 요청.
    @nonobjc class func fetchRequest(
        from startIndex: Int,
        ascending: Bool = true
    ) -> NSFetchRequest<Keyword> {
        let request = NSFetchRequest<Keyword>(entityName: Keyword.entityName)
        request.predicate = NSPredicate(format: "%d <= order", startIndex)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: ascending)]
        return request
    }
    
    /// 특정 구간의 키워드에 대한 검색 요청을 생성합니다.
    /// - Parameters:
    ///   - startIndex: 구간 시작 지점.
    ///   - endIndex: 구간 끝 지점.
    ///   - ascending: 오름차순 정렬 여부.
    /// - Returns: 키워드 검색 요청.
    @nonobjc class func fetchRequest(
        from startIndex: Int,
        to endIndex: Int,
        ascending: Bool = true
    ) -> NSFetchRequest<Keyword> {
        let request = NSFetchRequest<Keyword>(entityName: Keyword.entityName)
        request.predicate = NSPredicate(format: "%d <= order AND order <= %d", startIndex, endIndex)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: ascending)]
        return request
    }
}
