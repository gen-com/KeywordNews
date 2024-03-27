//
//  KeywordControllable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/2/24.
//

/// 키워드 관리자를 정의합니다.
protocol KeywordControllable {
    /// 현재 키워드 정보입니다.
    var currentKeywords: [any KeywordProtocol] { get async }
    
    /// 키워드를 추가합니다. 중복은 허용하지 않습니다.
    /// - Parameter value: 키워드 값.
    func add(_ keyword: some KeywordProtocol) async throws
    /// 키워드를 삭제합니다.
    /// - Parameter value: 삭제할 키워드.
    func remove(_ keyword: some KeywordProtocol) async throws
    /// 키워드의 순서를 변경합니다.
    /// - Parameters:
    ///   - source: 원래 위치.
    ///   - destination: 변경할 위치.
    func reorder(from source: Int, to destination: Int) async throws
}
