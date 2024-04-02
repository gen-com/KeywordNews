//
//  KeywordProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//

/// 키워드 정보 모델을 정의합니다.
protocol KeywordProtocol: Hashable {
    /// 키워드 값.
    var value: String { get }
    /// 순서 값.
    var order: Int { get }
    /// 저장된 여부.
    var isSaved: Bool { get }
}
