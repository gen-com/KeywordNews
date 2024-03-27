//
//  NewsControllable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import Foundation

/// 뉴스 관리자를 정의합니다.
protocol NewsControllable: Actor {
    /// 키워드별 뉴스 정보에 매핑되는 딕셔너리입니다.
    var keywordNewsDictionary: [KeywordWrapper: any NewsInformationProtocol] { get }
    
    /// 저장된 키워드들에 대한 초기 뉴스 정보를 생성합니다.
    /// - Parameter keywords: 저장된 키워드.
    func setStoredKeywords(_ keywords: [some KeywordProtocol]) async
    /// 특정 키워드에 대한 뉴스를 검색합니다.
    /// - Parameters:
    ///   - keyword: 뉴스를 가져오고자 하는 키워드.
    ///   - isArchive: 보관됨 필터 여부.
    func fetchNews(for keyword: some KeywordProtocol, withSession session: URLSession, archiveFilter: Bool) async throws
    /// 특정 키워드에 대한 뉴스를 새로고침합니다.
    /// - Parameter keyword: 새로고침 하려는 키워드.
    func refreshNews(for keyword: some KeywordProtocol, withSession session: URLSession) async throws
    /// 새로운 키워드에 대해, 메모리에 있던 뉴스를 디스크로 저장합니다.
    /// - Parameter keyword: 뉴스를 저장하려는 키워드.
    func addNews(for keyword: some KeywordProtocol) async throws
    /// 특정 키워드와 관련된 뉴스들을 제거합니다.
    /// - Parameter keyword: 없애려는 뉴스의 키워드.
    func removeNews(for keyword: some KeywordProtocol) async throws
    /// 특정 기간 이내의 뉴스를 제거합니다.
    /// - Parameter days: 기준 일수.
    func removeNews(orderThanOrEqual date: Date) async throws
    /// 원하는 뉴스를 아카이브(보관)합니다.
    /// - Parameters:
    ///   - news: 원하는 뉴스.
    ///   - keyword: 뉴스의 키워드.
    func changeArchiveState(of news: some NewsProtocol) async throws
}
