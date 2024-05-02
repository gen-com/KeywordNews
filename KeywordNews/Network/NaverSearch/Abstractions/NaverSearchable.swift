//
//  NaverSearchable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/12/24.
//

import Foundation

protocol NaverSearchable {
    /// 검색을 수행할 경로 타입.
    associatedtype Path
    
    /// 경로, 매개변수, 세션을 지정해서 검색을 수행합니다.
    /// - Parameters:
    ///   - path: 검색할 경로.
    ///   - parameter: 매개변수.
    ///   - session: 연결 세션.
    /// - Returns: 검색 결과.
    static func search<T>(
        for path: Path,
        with parameter: Encodable,
        andSession session: URLSession
    ) async throws -> any SearchResultProtocol<T> where T: Codable
}
