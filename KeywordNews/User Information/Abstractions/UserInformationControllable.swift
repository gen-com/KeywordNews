//
//  UserInformationControllable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/16/24.
//

/// 사용자 정보 관리자를 정의합니다.
protocol UserInformationControllable {
    /// 현재 사용자 정보입니다.
    var currentUserInformation: any UserInformationProtocol { get async throws }
    /// 뉴스 만료 일을 설정합니다.
    /// - Parameter days: 설정할 일 수.
    func setNewsExpirationDays(_ days: Int) async throws
}
