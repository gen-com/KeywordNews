//
//  SearchResultProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import Foundation

protocol SearchResultProtocol<Item>: Codable {
    /// 검색 항목 타입.
    associatedtype Item: Codable
    
    /// 요청 시각.
    var requestDate: String { get }
    /// 총 검색 결과량.
    var totalItemAmount: Int { get }
    /// 받아온 결과값 시작 지점.
    var startIndex: Int { get }
    /// 받아온 결과값 표시량.
    var itemAmount: Int { get }
    /// 요청한 항목.
    var items: [Item] { get }
}
