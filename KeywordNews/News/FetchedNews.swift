//
//  FetchedNews.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/31/24.
//

import Foundation

/// 불러온 뉴스 입니다.
struct FetchedNews: NewsProtocol {
    let title: String
    let content: String
    let link: String
    let order: Date
    var isArchived: Bool
    
    // MARK: - Initializer
    
    init(_ news: any NewsProtocol) {
        title = news.title
        content = news.content
        link = news.link
        order = news.order
        isArchived = news.isArchived
    }
}
