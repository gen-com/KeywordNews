//
//  Requestable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/17.
//

import Foundation

/// 요청 가능한 유형을 정의합니다.
protocol Requestable {
    /// 요청 경로 타입.
    associatedtype Path
    /// 필수 요소인 경로를 설정하며 요청을 생성합니다.
    /// - Parameter path: 경로 정보.
    init(path: Path) throws
    
    /// 생성한 요청으로 서버와 통신합니다.
    /// - Parameter session: 사용할 세션.
    /// - Returns: 요청을 통해 받은 응답.
    func fetch(withSession session: URLSession) async throws -> ResponseProtocol
    /// 요청의 HTTP 메소드를 설정합니다. 기본값은 GET입니다.
    /// - Parameter method: HTTP 메소드.
    /// - Returns: HTTP 메소드가 설정된 요청.
    func httpMethod(_ method: HTTPMethod) -> Self
    /// 요청의 헤더를 설정합니다.
    /// - Parameter header: 문자열 딕셔너리 형태의 HTTP 헤더.
    /// - Returns: 헤더가 설정된 요청.
    func httpHeader(_ header: [String: String]) -> Self
    /// 요청의 body에 부가적인 데이터를 추가합니다.
    /// - Parameter data: 추가할 데이터.
    /// - Returns: 데이터가 추가된 요청.
    func data(_ data: some Encodable) throws -> Self
    /// 요청의 query에 부가적인 데이터를 추가합니다.
    /// - Parameter parameter: 인코딩이 가능한 형태의 인스턴스.
    /// - Returns: query 파라미터가 추가된 요청.
    func parameter(_ parameter: some Encodable) throws -> Self
}
