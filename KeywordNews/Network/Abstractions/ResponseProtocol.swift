//
//  ResponseProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/23.
//

import Foundation

protocol ResponseProtocol {
    /// 요청의 응답 타입.
    typealias Input = (data: Data, urlResponse: HTTPURLResponse)
    
    /// 응답을 검증합니다.
    /// - Returns: 응답 데이터.
    func verifyResponse() throws -> Data
}
