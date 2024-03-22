//
//  NewsInformationProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/18/24.
//

import Foundation

/// 뉴스를 관리하기 위해 필요한 정보를 정의합니다.
protocol NewsInformationProtocol {
    /// 대상 키워드.
    var keyword: any KeywordProtocol { get }
    /// 현재 뉴스 요청중인지 여부.
    var isFetching: Bool { get set }
    /// 뉴스를 검색할 수 있는지 여부.
    var isSearchAvailable: Bool { get set }
    /// 가져올 수 있는 뉴스를 모두 불러왔는지 여부.
    var didFetchAll: Bool { get set }
    /// 예전 저장된 뉴스 중 최신 업데이트 날짜.
    var lastSavedNewsDate: Date? { get set }
    /// 다음 뉴스 검색 위치
    var nextNewsSearchPosition: Int { get set }
    /// 현재 가져온 뉴스 모음.
    var newsList: [any NewsProtocol] { get }
    
    /// 뉴스를 추가합니다.
    /// - Parameter news: 추가할 뉴스 리스트.
    /// - Returns: 중복으로 추가하지 못한 뉴스의 수.
    @discardableResult
    mutating func append(listOfNews: [any NewsProtocol]) -> Int
    mutating func removeAllNews()
}
