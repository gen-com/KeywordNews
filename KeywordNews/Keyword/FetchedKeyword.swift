//
//  FetchedKeyword.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/31/24.
//

/// 불러온 키워드 입니다.
struct FetchedKeyword: KeywordProtocol {
    let value: String
    let order: Int
    let isSaved: Bool
    
    // MARK: - Initializer
    
    init(_ keyword: any KeywordProtocol) {
        value = keyword.value
        order = keyword.order
        isSaved = true
    }
}
