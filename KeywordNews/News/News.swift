//
//  News+CoreDataClass.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/6/24.
//
//

import CoreData

final class News: NSManagedObject, NewsProtocol {
    /// 뉴스의 키워드값.
    @NSManaged var keywordValue: String
    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var link: String
    @NSManaged var order: Date
    @NSManaged var isArchived: Bool
    
    // MARK: - Type property
    
    /// 엔티티 이름.
    static let entityName = "\(News.self)"
    
    // MARK: - Type method
    
    /// 찾으려는 뉴스와 같은 링크를 가진 제약 조건을 생성합니다.
    /// - Parameter link: 뉴스 링크.
    /// - Returns: 링크 제약 조건.
    static func predicate(for link: String) -> NSPredicate {
        NSPredicate(format: "%K = %@", #keyPath(News.link), link)
    }
    
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
        offset: Int = 0,
        archiveFilter: Bool = false
    ) -> NSFetchRequest<News> {
        let request = NSFetchRequest<News>(entityName: News.entityName)
        request.predicate = archiveFilter
        ? NSPredicate(
            format: "%K = %@ && %K = %@",
            #keyPath(News.keywordValue),
            keyword.value,
            #keyPath(News.isArchived),
            archiveFilter as NSNumber
        )
        : NSPredicate(format: "%K = %@", #keyPath(News.keywordValue), keyword.value)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(News.order), ascending: false)]
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
        request.predicate = predicate(for: link)
        return request
    }
    
    /// 특정 기간을 넘는 뉴스 요청을 생성합니다.
    /// - Parameter date: 기준이 될 날짜.
    /// - Returns: 뉴스 요청.
    @nonobjc class func fetchRequest(orderThanOrEqual date: Date) -> NSFetchRequest<News> {
        let request = NSFetchRequest<News>(entityName: News.entityName)
        request.predicate = NSPredicate(
            format: "%K <= %@ && %K = %@",
            #keyPath(News.order),
            date as NSDate,
            #keyPath(News.isArchived),
            false as NSNumber
        )
        return request
    }
}
