//
//  FetchedUserInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/30/24.
//

struct FetchedUserInformation: UserInformationProtocol {
    let newsExpirationDays: Int
    
    // MARK: - Initializers
    
    init(_ userInformation: UserInformationProtocol) {
        newsExpirationDays = userInformation.newsExpirationDays
    }
}
