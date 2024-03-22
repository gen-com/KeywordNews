//
//  DateFormat.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 10/3/23.
//

import Foundation

/// 날짜 양식.
enum DateFormat: String {
    /// "Mon, 26 Sep 2016 07:50:00 +0900" 양식
    case naver = "E, d MMM yyyy HH:mm:ss Z"
    
    /// 지역 정보.
    var locale: Locale {
        switch self {
        case .naver: return Locale(identifier: "en-US")
        }
    }
}
