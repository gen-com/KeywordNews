//
//  NaverSearcher+Response.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/23.
//

import Foundation

extension NaverSearcher {
    struct Response: ResponseProtocol {
        /// 요청을 통해 받은 응답을 입력으로 받습니다.
        private let input: Input
        
        // MARK: - Initializer
        
        init(_ input: Input) {
            self.input = input
        }
        
        // MARK: ResponseProtocol conformance
        
        /// 응답으로 유효한 값이 왔는지 검증합니다.
        func verifyResponse() throws -> Data {
            let status = Status(code: input.urlResponse.statusCode)
            switch status {
            case .success:
                return input.data
            default:
                let responseError = try input.data.decodeJSON(ResponseError.self)
                throw Error.serverError(responseError.message)
            }
        }
    }
    
    // MARK: - Response Status
    
    enum Status: Int {
        /// 성공.
        case success = 200
        /// 잘못된 요청.
        case badRequest = 400
        /// 인증 실패.
        case authenticationFail = 401
        /// 요청 실패.
        case requestFail = 403
        /// 잘못된 URL.
        case badURL = 404
        /// 잘못된 HTTP 메소드.
        case badHTTPMethod = 405
        /// 요청 가능 한도 초과.
        case exceedRequestLimit = 429
        /// 서버 내부 오류.
        case serverError = 500
        /// 잘못된 응답.
        case badURLResponse = 600
        /// 알 수 없는 오류.
        case unknown = -1
        
        init(code: Int) {
            if let status = Status(rawValue: code) {
                self = status
            } else {
                self = .unknown
            }
        }
    }
    
    // MARK: - Server error type
    
    struct ResponseError: Decodable {
        /// 오류에 대한 정보.
        let message: String
        /// 오류 코드.
        let code: String
        
        enum CodingKeys: String, CodingKey {
            case message = "errorMessage"
            case code = "errorCode"
        }
    }
}
