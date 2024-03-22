//
//  SearchKeyword.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/7/24.
//

/// 검색할 키워드 구현체입니다.
struct SearchKeyword: KeywordProtocol {
    var value: String
    var order: Int
    
    // MARK: - Initializer
    
    init(value: String, order: Int) {
        self.value = value
        self.order = order
    }
}
