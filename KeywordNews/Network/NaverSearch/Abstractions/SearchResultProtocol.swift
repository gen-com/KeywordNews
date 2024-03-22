//
//  SearchResultProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import Foundation

/// 검색 결과 타입을 정의합니다.
protocol SearchResultProtocol<Item>: Codable {
    /// 검색 항목 타입.
    associatedtype Item: Codable
    
    /// 요청 시각.
    var requestDate: String { get }
    /// 총 검색 결과량.
    var totalResult: Int { get }
    /// 받아온 결과값 시작 지점.
    var itemStartIndex: Int { get }
    /// 받아온 결과값 표시량.
    var itemAmount: Int { get }
    /// 요청한 항목.
    var items: [Item] { get }
}

/// 뉴스 검색 결과 별칭.
typealias NewsSearchResult = any SearchResultProtocol<NaverSearcher.News>
