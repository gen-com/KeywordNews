//
//  NewsControllable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import Foundation

/// 뉴스 관리자를 정의합니다.
protocol NewsControllable: Actor {
    /// 관리하고 있는 뉴스 정보입니다.
    var information: NewsInformationProtocol { get }
    
    /// 요청 상태를 설정합니다.
    /// - Parameter value: 할당할 상태.
    func setFetchState(as value: Bool)
    /// 특정 키워드에 대한 뉴스를 검색합니다.
    /// - Parameter session: 요청 세션.
    func fetchNews(withSession session: URLSession) async throws
    /// 특정 키워드에 대한 뉴스를 새로고침합니다.
    /// - Parameter session: 요청 세션.
    func refreshNews(withSession session: URLSession) async throws
    /// 메모리에 있던 뉴스를 디스크로 저장합니다.
    func saveNews() async throws
    /// 메모리에 있던 뉴스를 제거합니다.
    func removeNews() async throws
    /// 특정 기간 이내의 뉴스를 제거합니다.
    /// - Parameter days: 기준 일수.
    func removeNews(orderThanOrEqual date: Date) async throws
    /// 원하는 뉴스를 아카이브(보관)합니다.
    /// - Parameter news: 원하는 뉴스.
    func changeArchiveState(of news: any NewsProtocol) async throws
}
