//
//  FetchedUserInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/30/24.
//

/// 불러온 사용자 정보입니다.
struct FetchedUserInformation: UserInformationProtocol {
    let newsExpirationDays: Int
    
    // MARK: - Initializer
    
    init(_ userInformation: UserInformationProtocol) {
        newsExpirationDays = userInformation.newsExpirationDays
    }
}
