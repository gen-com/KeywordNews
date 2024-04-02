//
//  NewsInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/18/24.
//

import Foundation

/// 뉴스 정보 구현체입니다.
struct NewsInformation: NewsInformationProtocol {
    var keyword: any KeywordProtocol
    var isFetching: Bool
    var isSearchAvailable: Bool
    var didFetchAll: Bool
    var nextNewsSearchPosition: Int
    var newsList: [any NewsProtocol]
    private var newsLinkSet: Set<String>
    
    // MARK: - initializer
    
    init(keyword: any KeywordProtocol) {
        self.keyword = keyword
        isFetching = false
        isSearchAvailable = true
        didFetchAll = false
        nextNewsSearchPosition = 1
        newsList = []
        newsLinkSet = []
    }
    
    // MARK: - NewsInformationProtocol conformance
    
    mutating func updateKeyword(to keyword: any KeywordProtocol) {
        self.keyword = keyword
    }
    
    mutating func setFetchingState(as value: Bool) {
        isFetching = value
    }
    
    mutating func update(basedOn newsFetchResult: NewsFetchResultProtocol) {
        insert(listOfNews: newsFetchResult.newsList)
        isSearchAvailable = newsList.count < newsFetchResult.searchLimit && !newsFetchResult.doesOverlapSavedNews
        nextNewsSearchPosition = newsFetchResult.searchPosition + newsFetchResult.newsList.count
        didFetchAll = keyword.isSaved
        ? newsFetchResult.newsList.isEmpty : newsFetchResult.searchLimit <= nextNewsSearchPosition
    }
    
    mutating func refresh() {
        nextNewsSearchPosition = 1
        isSearchAvailable = true
        didFetchAll = false
        removeAllNews()
    }
    
    mutating func insert(listOfNews newsList: [any NewsProtocol]) {
        for news in newsList where !newsLinkSet.contains(news.link) {
            newsLinkSet.insert(news.link)
            self.newsList.append(news)
        }
    }
    
    mutating func removeAllNews() {
        newsList.removeAll()
    }
    
    mutating func changeArchiveState(of news: any NewsProtocol) throws {
        guard let targetIndex = newsList.firstIndex(where: { $0.link == news.link })
        else { throw CommonError.valueNotFound }
        newsList[targetIndex].isArchived.toggle()
    }
}
