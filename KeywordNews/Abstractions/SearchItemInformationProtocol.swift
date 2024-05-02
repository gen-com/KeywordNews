//
//  InformationProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/18/24.
//

import Foundation

protocol SearchItemInformationProtocol<Item> {
    /// 정보를 다룰 항목의 유형.
    associatedtype Item
    /// 대상 키워드.
    var keyword: KeywordProtocol { get }
    /// 요청 상태.
    var fetchState: FetchState { get }
    /// 현재 가져온 뉴스 모음.
    var items: [Item] { get }
    /// 마지막 뉴스 요청 날짜.
    var lastRequestDate: Date? { get }
    /// 뉴스를 검색할 수 있는지 여부.
    var isSearchAvailable: Bool { get }
    /// 가져올 수 있는 뉴스를 모두 불러왔는지 여부.
    var didFetchAll: Bool { get }
    /// 다음 뉴스 검색 위치
    var nextNewsSearchPosition: Int { get }
    /// 저장한 뉴스 중 가장 최신 뉴스의 순서 날짜.
    var lastStoredNewsDate: Date? { get }
    /// 보관중인 뉴스만을 불러올지 구분하는 값.
    var archiveFlag: Bool { get }
    
    /// 키워드를 최신화합니다.
    /// - Parameter keyword: 최신화할 키워드.
    mutating func updateKeyowrd(to keyword: KeywordProtocol)
    /// 요청 상태를 변경합니다.
    /// - Parameter state: 변경할 상태.
    mutating func setFetchState(as state: FetchState)
    /// 뉴스 목록을 추가합니다. 단, 중복은 허용하지 않습니다.
    /// - Parameter newsList: 추가할 뉴스 목록.
    mutating func insert(listOfItem items: [Item])
    /// 뉴스 검색 결과를 바탕으로 뉴스 정보를 최신화합니다.
    /// - Parameter newsSearchResult: 뉴스 검색 결과.
    mutating func update(basedOn fetchResult: any FetchResultProtocol<Item>)
    /// 뉴스 정보를 새로 고칩니다.
    mutating func refresh()
    /// 해당 뉴스의 보관 여부를 변경합니다.
    /// - Parameters:
    ///   - news: 보관 여부를 설정할 뉴스.
    ///   - state: 설정할 값.
    mutating func setArchiveState(of news: Item, as state: Bool) throws
    /// 저장한 뉴스 중 가장 최신 뉴스의 순서 날짜를 설정합니다.
    /// - Parameter date: 설정할 날짜.
    mutating func setLastStoredNewsDate(as date: Date)
}
