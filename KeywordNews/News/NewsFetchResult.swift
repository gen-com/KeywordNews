//
//  NewsFetchResult.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 4/1/24.
//

import Foundation

/// 뉴스를 항목으로 하는 가져오기 결과 프로토콜의 별칭입니다.
typealias NewsFetchResultProtocol = any FetchResultProtocol<NewsProtocol>

struct NewsFetchResult: FetchResultProtocol {
    var requestDate: Date?
    var searchLimit: Int
    var searchPosition: Int
    var doesOverlapSavedItems: Bool
    var items: [NewsProtocol]
    
    // MARK: - Initializer
    
    init() {
        searchLimit = Constant.defaultSearchLimit
        searchPosition = 1
        doesOverlapSavedItems = false
        items = []
    }
}

// MARK: - NewsFetchResultProtocol conformance

extension NewsFetchResult {
    mutating func update(referringTo searchResult: any SearchResultProtocol) {
        requestDate = try? searchResult.requestDate.toDate(format: .naver)
        searchLimit = min(searchResult.totalItemAmount, Constant.defaultSearchLimit)
        searchPosition = searchResult.startIndex
    }
    
    mutating func setDoesOverlapSavedItems(as value: Bool) {
        doesOverlapSavedItems = value
    }
    
    mutating func append(contentsOf items: [NewsProtocol]) {
        self.items.append(contentsOf: items)
    }
}

// MARK: - Constants

extension NewsFetchResult {
    private enum Constant {
        static let defaultSearchLimit = 100
    }
}
