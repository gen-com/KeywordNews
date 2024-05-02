//
//  UserInformationControllable.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/16/24.
//

protocol UserInformationControllable {
    /// 현재 사용자 정보입니다.
    var currentUserInformation: UserInformationProtocol? { get async }
    
    /// 기본값을 가진 사용자 정보를 생성합니다.
    func createDefaultUserInformation() async throws
    /// 뉴스 만료 일을 설정합니다.
    /// - Parameter days: 설정할 일 수.
    func setNewsExpirationDays(_ days: Int) async throws
}
