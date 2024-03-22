//
//  UserInformationProtocol.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//

/// 사용자 정보 모델을 정의합니다.
protocol UserInformationProtocol {
    /// 뉴스 만료 일자.
    var newsExpirationDays: Int { get }
}
