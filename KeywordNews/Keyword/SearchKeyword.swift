//
//  SearchKeyword.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/7/24.
//

/// 검색할 키워드 구현체입니다.
struct SearchKeyword: KeywordProtocol {
    let value: String
    var order: Int
    let isSaved: Bool
    
    // MARK: - Initializer
    
    init(value: String) {
        self.value = value
        order = 0
        isSaved = false
    }
}
