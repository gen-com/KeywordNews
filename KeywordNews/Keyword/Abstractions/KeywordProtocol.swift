//
//  KeywordProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//

protocol KeywordProtocol {
    /// 키워드 값.
    var value: String { get }
    /// 순서 값.
    var order: Int { get }
    /// 저장된 여부.
    var isSaved: Bool { get }
}
