//
//  UserInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//
//

import CoreData

/// 코어 데이터 기반의 사용자 정보 구현입니다.
final class UserInformation: NSManagedObject, UserInformationProtocol {
    
    // MARK: - Attributes
    
    @NSManaged var newsExpirationDays: Int
    
    // MARK: - Fetch request
    
    /// 모든 사용자 정보에 대한 요청을 생성합니다.
    /// - Returns: 모든 사용자 정보에 대한 요청.
    @nonobjc class func fetchRequest() -> NSFetchRequest<UserInformation> {
        NSFetchRequest<UserInformation>(entityName: "UserInformation")
    }
}
