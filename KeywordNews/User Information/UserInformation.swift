//
//  UserInformation.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/11/24.
//
//

import CoreData

final class UserInformation: NSManagedObject, UserInformationProtocol {
    @NSManaged var newsExpirationDays: Int
    
    // MARK: - Type Property
    
    /// 엔티티 이름.
    static let entityName = "\(UserInformation.self)"
    
    // MARK: - Fetch request
    
    /// 모든 사용자 정보에 대한 요청을 생성합니다.
    /// - Returns: 모든 사용자 정보에 대한 요청.
    @nonobjc class func fetchRequest() -> NSFetchRequest<UserInformation> {
        NSFetchRequest<UserInformation>(entityName: UserInformation.entityName)
    }
}
