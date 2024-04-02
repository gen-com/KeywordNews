//
//  NewsFetchResult.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 4/1/24.
//

import Foundation

struct NewsFetchResult: NewsFetchResultProtocol {
    var searchLimit: Int
    var searchPosition: Int
    var doesOverlapSavedNews: Bool
    var newsList: [any NewsProtocol]
    
    init() {
        searchLimit = Constant.defaultSearchLimit
        searchPosition = Constant.defaultSearchLimit
        doesOverlapSavedNews = false
        newsList = []
    }
    
    mutating func setSearchLimit(_ amount: Int) {
        searchLimit = min(amount, Constant.defaultSearchLimit)
    }
    
    // MARK: - Constants
    
    private enum Constant {
        static let defaultSearchLimit = 100
    }
}
