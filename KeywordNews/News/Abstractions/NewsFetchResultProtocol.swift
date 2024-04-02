//
//  NewsFetchResult.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 4/1/24.
//

/// 뉴스 가져오기 결과를 정의합니다.
protocol NewsFetchResultProtocol {
    /// 검색 제한값.
    var searchLimit: Int { get }
    /// 검색 위치.
    var searchPosition: Int { get set }
    /// 저장한 뉴스와 겹치는지 여부.
    var doesOverlapSavedNews: Bool { get set }
    /// 가져온 뉴스.
    var newsList: [any NewsProtocol] { get set }
    
    /// 총 검색량으로 제한값을 설정합니다.
    /// - Parameter amount: 총 검색량.
    mutating func setSearchLimit(_ amount: Int)
}
