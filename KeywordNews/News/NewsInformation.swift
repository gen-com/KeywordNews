//
//  NewsInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/18/24.
//

import Foundation

/// 뉴스 정보 구현체입니다.
struct NewsInformation: NewsInformationProtocol {
    let keyword: any KeywordProtocol
    var isFetching: Bool
    var isSearchAvailable: Bool
    var didFetchAll: Bool
    var lastSavedNewsDate: Date?
    var nextNewsSearchPosition: Int
    var newsList: [any NewsProtocol]
    
    // MARK: - initializer
    
    init(
        keyword: some KeywordProtocol,
        isFetching: Bool = false,
        isSearchAvailable: Bool = true,
        didFetchAll: Bool = false,
        lastSavedNewsDate: Date? = nil,
        nextNewsSearchPosition: Int = 1,
        newsList: [any NewsProtocol] = []
    ) {
        self.keyword = keyword
        self.isFetching = isFetching
        self.isSearchAvailable = isSearchAvailable
        self.didFetchAll = didFetchAll
        self.lastSavedNewsDate = lastSavedNewsDate
        self.nextNewsSearchPosition = nextNewsSearchPosition
        self.newsList = newsList
    }
    
    // MARK: - NewsInformationProtocol conformance
    
    mutating func append(listOfNews: [any NewsProtocol]) -> Int {
        var newsLinkSet = Set(newsList.map { $0.link })
        var duplicateCount = 0
        for news in listOfNews {
            if newsLinkSet.contains(news.link) {
                duplicateCount += 1
            } else {
                newsLinkSet.insert(news.link)
                newsList.append(news)
            }
        }
        return duplicateCount
    }
    
    mutating func removeAllNews() {
        newsList.removeAll()
    }
}
