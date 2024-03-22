//
//  PresentableError.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 11/25/23.
//

import Foundation

/// 표현 가능한 오류 유형.
protocol PresentableError: Error {
    /// 오류 제목.
    var title: String { get }
    /// 오류 설명.
    var description: String { get }
}
