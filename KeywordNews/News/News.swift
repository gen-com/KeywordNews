//
//  News+CoreDataClass.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/6/24.
//
//

import CoreData

/// 코어 데이터 기반으로 구현된 뉴스입니다.
final class News: NSManagedObject, NewsProtocol {
    @NSManaged var keywordValue: String
    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var link: String
    @NSManaged var order: Date
    @NSManaged var isArchived: Bool
    
    // MARK: - Type property
    
    /// 엔티티 이름.
    static let entityName = "\(News.self)"
    
    // MARK: - Fetch request
    
    /// 특정 키워드에 대한 최신 뉴스 요청을 생성합니다.
    /// - Parameters:
    ///   - keyword: 요청할 키워드.
    ///   - amount: 요청 수량.
    ///   - offset: 요청 시작 지점.
    /// - Returns: 최신 뉴스 요청.
    @nonobjc class func fetchRequest(
        for keyword: any KeywordProtocol,
        amount: Int? = nil,
        offset: Int = 0
    ) -> NSFetchRequest<News> {
        let request = NSFetchRequest<News>(entityName: News.entityName)
        request.predicate = NSPredicate(format: "keywordValue = %@", keyword.value)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
        if let amount {
            request.fetchLimit = amount
        }
        request.fetchOffset = offset
        return request
    }
    
    /// 특정 링크를 가지는 뉴스 검색 요청을 생성합니다.
    /// - Parameter link: 찾을 링크 값.
    /// - Returns: 뉴스 요청.
    @nonobjc class func fetchRequest(forCorresponding link: String) -> NSFetchRequest<News> {
        let request = NSFetchRequest<News>(entityName: News.entityName)
        request.predicate = NSPredicate(format: "link = %@", link)
        return request
    }
    
    /// 특정 링크를 가지는 뉴스 검색 요청을 생성합니다.
    /// - Parameter link: 찾을 링크 값.
    /// - Returns: 뉴스 요청.
    @nonobjc class func fetchRequest(orderThanOrEqual date: Date) -> NSFetchRequest<News> {
        let request = NSFetchRequest<News>(entityName: News.entityName)
        request.predicate = NSPredicate(format: "order <= %@ && isArchived = %@", date as NSDate, false as NSNumber)
        return request
    }
}
