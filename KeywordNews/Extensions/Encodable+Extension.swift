//
//  Encodable+Extension.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/17.
//

import Foundation

extension Encodable {
    /// 변수명과 값으로 딕셔너리를 만듭니다.
    /// - Returns: 딕셔너리.
    func dictionary() throws -> [String: Any] {
        let data = try self.encodeJSON()
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonObject as? [String: Any]
        else { throw CustomError.invalidConversion }
        return dictionary
    }
    
    /// 변수명과 값으로 문자열 딕셔너리를 만듭니다.
    /// - Returns: 문자열 딕셔너리.
    func stringDictionary() throws -> [String: String] {
        let dictionary = try self.dictionary()
        var stringDictionary = [String: String]()
        dictionary.forEach { stringDictionary.updateValue("\($0.value)", forKey: $0.key) }
        return stringDictionary
    }
    
    /// 데이터를 JSON으로 변환합니다.
    /// - Returns: JSON 데이터.
    func encodeJSON() throws -> Data {
        do { return try JSONEncoder().encode(self) }
        catch { throw CustomError.failToEncode }
    }
}
