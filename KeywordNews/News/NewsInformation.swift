//
//  NewsInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/18/24.
//

import Foundation

/// 뉴스를 항목으로 하는 정보 프로토콜의 별칭입니다.
typealias NewsInformationProtocol = any SearchItemInformationProtocol<NewsProtocol>

struct NewsInformation: SearchItemInformationProtocol {
    var keyword: KeywordProtocol
    var fetchState: FetchState
    var items: [NewsProtocol]
    var lastRequestDate: Date?
    var isSearchAvailable: Bool
    var didFetchAll: Bool
    var nextNewsSearchPosition: Int
    var lastStoredNewsDate: Date?
    let archiveFlag: Bool
    private var newsLinkSet: Set<String>
    
    // MARK: - Initializer
    
    init(keyword: KeywordProtocol, archiveFlag: Bool = false) {
        self.keyword = keyword
        fetchState = .idle
        items = []
        isSearchAvailable = true
        didFetchAll = false
        nextNewsSearchPosition = 1
        self.archiveFlag = archiveFlag
        newsLinkSet = []
    }
}

// MARK: - NewsInformationProtocol conformance
    
extension NewsInformation {
    mutating func updateKeyowrd(to keyword: KeywordProtocol) {
        self.keyword = keyword
    }
    
    mutating func setFetchState(as state: FetchState) {
        fetchState = state
    }
    
    mutating func insert(listOfItem items: [NewsProtocol]) {
        for news in items where !newsLinkSet.contains(news.link) {
            newsLinkSet.insert(news.link)
            self.items.append(news)
        }
    }
    
    mutating func update(basedOn newsFetchResult: NewsFetchResultProtocol) {
        lastRequestDate = newsFetchResult.requestDate
        insert(listOfItem: newsFetchResult.items)
        isSearchAvailable = items.count < newsFetchResult.searchLimit && !newsFetchResult.doesOverlapSavedItems
        nextNewsSearchPosition = newsFetchResult.searchPosition + newsFetchResult.items.count
        didFetchAll = keyword.isSaved
        ? newsFetchResult.items.isEmpty 
        : newsFetchResult.searchLimit <= nextNewsSearchPosition
    }
    
    mutating func refresh() {
        nextNewsSearchPosition = 1
        isSearchAvailable = true
        didFetchAll = false
        lastStoredNewsDate = items.first?.order
        items.removeAll()
    }
    
    mutating func setArchiveState(of news: NewsProtocol, as state: Bool) throws {
        guard let targetIndex = items.firstIndex(where: { $0.link == news.link })
        else { throw CommonError.valueNotFound }
        let targetNews = items.remove(at: targetIndex)
        if archiveFlag == false {
            let updatedNews = FetchedNews(
                title: targetNews.title,
                content: targetNews.content,
                link: targetNews.link,
                order: targetNews.order,
                isArchived: state
            )
            items.insert(updatedNews, at: targetIndex)
        }
    }
    
    mutating func setLastStoredNewsDate(as date: Date) {
        lastStoredNewsDate = date
    }
}
