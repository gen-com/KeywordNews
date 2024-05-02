//
//  PresentableError.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 11/25/23.
//

import Foundation

protocol PresentableError: Error {
    /// 오류 제목.
    var title: String { get }
    /// 오류 설명.
    var description: String { get }
}
