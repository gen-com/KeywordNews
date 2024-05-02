//
//  HTTPMethod.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/08/17.
//

enum HTTPMethod: String {
    /// GET(읽기) 요청 메소드.
    case get
    /// POST(쓰기) 요청 메소드.
    case post
    /// PUT(수정) 요청 메소드.
    case put
    /// DELETE(삭제) 요청 메소드.
    case delete
    
    /// 요청에 실제 사용하는 값.
    var value: String { self.rawValue.uppercased() }
}
