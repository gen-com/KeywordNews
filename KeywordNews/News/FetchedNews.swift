//
//  FetchedNews.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/31/24.
//

import Foundation

struct FetchedNews: NewsProtocol {
    let title: String
    let content: String
    let link: String
    let order: Date
    var isArchived: Bool
    
    // MARK: - Initializers
    
    init(title: String, content: String, link: String, order: Date, isArchived: Bool) {
        self.title = title
        self.content = content
        self.link = link
        self.order = order
        self.isArchived = isArchived
    }
    
    init(_ news: NewsProtocol) {
        title = news.title
        content = news.content
        link = news.link
        order = news.order
        isArchived = news.isArchived
    }
}
