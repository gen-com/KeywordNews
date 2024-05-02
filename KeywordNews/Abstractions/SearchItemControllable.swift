//
//  SearchItemControllable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import Foundation

protocol SearchItemControllable<Item> {
    /// 관리할 항목 유형.
    associatedtype Item
    /// 뉴스 정보에 저장한 뉴스 중 가장 최신 뉴스의 순서 날짜를 설정합니다.
    /// - Parameter newsInformation: 설정할 뉴스 정보.
    func setLastSavedItemDate(for information: inout any SearchItemInformationProtocol<Item>) async
    /// 특정 키워드에 대한 뉴스를 검색합니다.
    /// - Parameters:
    ///   - newsInformation: 검색을 위한 뉴스 정보.
    ///   - session: 요청 세션.
    func fetchItems(
        for information: inout any SearchItemInformationProtocol<Item>,
        withSession session: URLSession
    ) async throws
    /// 특정 키워드에 대한 뉴스를 새로고침합니다.
    /// - Parameters:
    ///   - newsInformation: 새로고침을 위한 뉴스 정보.
    ///   - session: 요청 세션.
    func refreshItems(
        for information: inout any SearchItemInformationProtocol<Item>,
        withSession session: URLSession
    ) async throws
    /// 메모리에 있던 뉴스를 디스크로 저장합니다.
    /// - Parameter newsInformation: 저장을 위한 뉴스 정보.
    func saveItems(of newsInformation: inout any SearchItemInformationProtocol<Item>) async throws
    /// 특정 기간 이내의 뉴스를 제거합니다.
    /// - Parameter days: 기준 일수.
    func removeItems(orderThanOrEqual date: Date) async throws
    /// 원하는 뉴스의 보관 상태를 설정합니다.
    /// - Parameters:
    ///   - news: 목표 뉴스.
    ///   - state: 설정할 상태.
    ///   - newsInformation: 목표 뉴스가 속한 뉴스 정보.
    func setArchiveState(
        of item: Item,
        as state: Bool,
        from information: inout any SearchItemInformationProtocol<Item>
    ) async throws
}
