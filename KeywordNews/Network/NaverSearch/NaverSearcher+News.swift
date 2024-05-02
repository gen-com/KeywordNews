//
//  NaverSearcher+News.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/17.
//

import Foundation

/// 뉴스 검색 결과 별칭.
typealias NewsSearchResult = any SearchResultProtocol<NaverSearcher.News>

extension NaverSearcher {
    struct NewsParameter: Codable {
        /// 검색 키워드.
        let keyword: String
        /// 요청할 품목량.
        let itemAmount: Int
        /// 요청할 품목 시작지점.
        let itemStartPoint: Int
        /// 정렬 방법.
        let sort: Sort
        
        enum CodingKeys: String, CodingKey {
            case keyword = "query"
            case itemAmount = "display"
            case itemStartPoint = "start"
            case sort
        }
        
        init(keyword: String, itemStartPoint: Int, itemAmount: Int) {
            self.keyword = keyword
            self.itemStartPoint = itemStartPoint
            self.itemAmount = itemAmount
            sort = .sim
        }
    }
    
    struct News: NewsProtocol, Codable {
        /// 뉴스 제목.
        let title: String
        /// 원본 뉴스 링크.
        let originalLink: String
        /// 네이버 뉴스 링크.
        let link: String
        /// 뉴스 내용.
        let content: String
        /// 출간 날짜.
        let pubDate: String
        
        var order: Date { Date() }
        var isArchived: Bool { 
            get { false }
            set {}
        }
        
        enum CodingKeys: String, CodingKey {
            case title
            case originalLink = "originallink"
            case link
            case content = "description"
            case pubDate
        }
    }
    
    enum Sort: String, Codable {
        /// similarity, 유사성, 정확성.
        case sim
        /// 날짜순, 시간순.
        case date
    }
}
