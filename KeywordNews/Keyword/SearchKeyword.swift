//
//  SearchKeyword.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/7/24.
//

struct SearchKeyword: KeywordProtocol {
    let value: String
    let order: Int
    let isSaved: Bool
    
    // MARK: - Initializer
    
    init(value: String) {
        self.value = value
        order = 0
        isSaved = false
    }
}
