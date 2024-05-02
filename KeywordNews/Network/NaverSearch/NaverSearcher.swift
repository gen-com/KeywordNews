//
//  NaverSearcher.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/12/24.
//

import Foundation

enum NaverSearcher: NaverSearchable {
    
    // MARK: - Searchable Conformance
    
    static func search<T>(
        for path: NaverOpenAPI.Path,
        with parameter: Encodable,
        andSession session: URLSession
    ) async throws -> any SearchResultProtocol<T> where T: Codable {
        try await Request(path: .news)
            .httpHeader(NaverOpenAPI.authenticationHeader)
            .parameter(parameter)
            .fetch(withSession: session)
            .verifyResponse()
            .decodeJSON(SearchResult<T>.self)
    }
    
    // MARK: - Search result
    
    struct SearchResult<Item>: SearchResultProtocol where Item: Codable {
        /// 요청 시각.
        var requestDate: String
        /// 총 검색 결과량.
        let totalItemAmount: Int
        /// 받아온 결과값 시작 지점.
        let startIndex: Int
        /// 받아온 결과값 표시량.
        let itemAmount: Int
        /// 요청한 항목.
        let items: [Item]
        
        enum CodingKeys: String, CodingKey {
            case requestDate = "lastBuildDate"
            case totalItemAmount = "total"
            case startIndex = "start"
            case itemAmount = "display"
            case items
        }
    }
    
    // MARK: - Error
    
    enum Error: PresentableError {
        /// 잘못된 URL.
        case badURL
        /// 잘못된 응답.
        case badResponse
        /// 클라이언트 상의 네트워크 오류.
        case clientNetworkError
        /// 서버 오류.
        case serverError(String)
        
        var title: String {
            "네이버 검색 오류"
        }
        
        var description: String {
            switch self {
            case .badURL:
                return "잘못된 URL입니다."
            case .badResponse:
                return "잘못된 응답입니다."
            case .clientNetworkError:
                return "클라이언트에서 요청을 수행하는데 실패했습니다."
            case .serverError(let description):
                return description
            }
        }
    }
}
