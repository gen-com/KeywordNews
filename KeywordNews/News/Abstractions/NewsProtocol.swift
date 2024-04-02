//
//  NewsProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2023/09/16.
//

import Foundation

/// 뉴스를 표현하는 유형.
protocol NewsProtocol: Hashable {
    /// 뉴스 제목.
    var title: String { get }
    /// 뉴스 내용.
    var content: String { get }
    /// 뉴스 URL.
    var link: String { get }
    /// 뉴스 순서.
    var order: Date { get }
    /// 뉴스 보관 여부.
    var isArchived: Bool { get set }
}
