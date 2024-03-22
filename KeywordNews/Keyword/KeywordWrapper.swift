//
//  KeywordWrapper.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/19/24.
//

/// 해시가 가능하도록 키워드 프로토콜 감싼 열거형입니다.
enum KeywordWrapper: Hashable {
    /// 키워드 내용.
    case content(any KeywordProtocol)
    
    // MARK: - Hashable & Equatable conformance
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .content(keyword):
            hasher.combine(keyword.value)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.content(lhsKeyword), .content(rhsKeyword)):
            return lhsKeyword.value == rhsKeyword.value
        }
    }
}
