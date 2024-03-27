//
//  Data+Extension.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 10/1/23.
//

import Foundation

extension Data {
    /// JSON 데이터를 원하는 값으로 변환합니다.
    /// - Parameter output: 변환할 타입.
    /// - Returns: 변환된 값.
    func decodeJSON<Output: Decodable>(_ output: Output.Type) throws -> Output {
        do { return try JSONDecoder().decode(output, from: self) }
        catch { throw CommonError.failToDecode }
    }
}
