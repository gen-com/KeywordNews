//
//  NaverSearcher+Request.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/21.
//

import Foundation

extension NaverSearcher {
    struct Request: Requestable {
        private let url: URL
        private var httpHeader: [String: String]
        private var httpMethod: HTTPMethod
        private var data: Data?
        private var parameter: [String: String]
        
        // MARK: - Type method
        
        /// 경로를 받아 요청할 곳의 URL을 생성합니다.
        /// - Parameter path: 요청할 경로.
        /// - Returns: 요청할 URL.
        private static func createURL(for path: NaverOpenAPI.Path) throws -> URL {
            var urlComponents = URLComponents()
            urlComponents.scheme = NaverOpenAPI.scheme
            urlComponents.host = NaverOpenAPI.host
            urlComponents.path = path.rawValue
            guard let url = urlComponents.url
            else { throw Error.badURL }
            return url
        }
        
        // MARK: - Requestable conformance
        
        init(path: NaverOpenAPI.Path) throws {
            url = try Request.createURL(for: path)
            httpHeader = [:]
            httpMethod = .get
            parameter = [:]
        }
        
        func fetch(withSession session: URLSession) async throws -> ResponseProtocol {
            guard let (data, urlResponse) = try? await session.data(for: urlRequest())
            else { throw Error.clientNetworkError }
            guard let httpURLResponse = urlResponse as? HTTPURLResponse
            else { throw Error.badResponse }
            return Response((data, httpURLResponse))
        }
        
        /// 요청을 생성합니다.
        /// - Returns: 요청.
        private func urlRequest() -> URLRequest {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = httpMethod.value
            httpHeader.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
            let queryItems = parameter.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlRequest.url?.append(queryItems: queryItems)
            urlRequest.httpBody = data
            return urlRequest
        }
        
        func httpMethod(_ method: HTTPMethod) -> Self {
            var copy = self
            copy.httpMethod = method
            return copy
        }
        
        func httpHeader(_ header: [String: String]) -> Self {
            var copy = self
            copy.httpHeader = header
            return copy
        }
        
        func data(_ data: some Encodable) throws -> Self {
            var copy = self
            copy.data = try data.encodeJSON()
            return copy
        }
        
        func parameter(_ parameter: some Encodable) throws -> Self {
            var copy = self
            copy.parameter = try parameter.stringDictionary()
            return copy
        }
    }
}
