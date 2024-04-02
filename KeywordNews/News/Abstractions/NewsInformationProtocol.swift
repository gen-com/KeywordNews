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
    var isFetching: Bool { get }
    /// 뉴스를 검색할 수 있는지 여부.
    var isSearchAvailable: Bool { get }
    /// 가져올 수 있는 뉴스를 모두 불러왔는지 여부.
    var didFetchAll: Bool { get }
    /// 다음 뉴스 검색 위치
    var nextNewsSearchPosition: Int { get }
    /// 현재 가져온 뉴스 모음.
    var newsList: [any NewsProtocol] { get }
    
    /// 키워드를 최신화합니다.
    /// - Parameter keyword: 최신화할 키워드.
    mutating func updateKeyword(to keyword: any KeywordProtocol)
    /// 요청 상태를 설정합니다.
    /// - Parameter value: 할당할 상태.
    mutating func setFetchingState(as value: Bool)
    /// 뉴스 검색 결과를 바탕으로 뉴스 정보를 최신화합니다.
    /// - Parameter newsSearchResult: 뉴스 검색 결과.
    mutating func update(basedOn newsFetchResult: NewsFetchResultProtocol)
    /// 뉴스 정보를 새로 고칩니다.
    mutating func refresh()
    /// 뉴스 목록을 추가합니다. 단, 중복은 허용하지 않습니다.
    /// - Parameter newsList: 추가할 뉴스 목록.
    mutating func insert(listOfNews newsList: [any NewsProtocol])
    /// 모든 뉴스를 제거합니다.
    mutating func removeAllNews()
    /// 해당 뉴스의 보관 여부를 변경합니다.
    /// - Parameter news: 보관 여부를 변경할 뉴스.
    mutating func changeArchiveState(of news: any NewsProtocol) throws
}
