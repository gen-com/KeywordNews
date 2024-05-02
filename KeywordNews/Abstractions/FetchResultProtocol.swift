//
//  FetchResultProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 4/1/24.
//

import Foundation

protocol FetchResultProtocol<Item> {
    /// 가져온 항목 유형.
    associatedtype Item
    /// 요청 날짜.
    var requestDate: Date? { get }
    /// 검색 제한값.
    var searchLimit: Int { get }
    /// 검색 위치.
    var searchPosition: Int { get }
    /// 저장한 항목와 겹치는지 여부.
    var doesOverlapSavedItems: Bool { get }
    /// 가져온 항목들.
    var items: [Item] { get }
    
    /// 검색결과를 통해 최신화합니다.
    /// - Parameter searchResult: 검색결과
    mutating func update(referringTo searchResult: any SearchResultProtocol)
    /// 저장한 항목와 겹치는지 여부를 설정합니다.
    /// - Parameter value: 설정할 값.
    mutating func setDoesOverlapSavedItems(as value: Bool)
    /// 가져온 항목을 추가합니다.
    /// - Parameter items: 추가할 항목.
    mutating func append(contentsOf items: [Item])
}
