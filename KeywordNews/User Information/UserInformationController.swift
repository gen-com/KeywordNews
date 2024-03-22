//
//  UserInformationController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/16/24.
//

import CoreData

/// 사용자 정보를 관리하는 구현체입니다.
struct UserInformationController: UserInformationControllable {
    var persistentController: Persistable
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Initializer
    
    init(persistentController: Persistable) {
        self.persistentController = persistentController
        backgroundContext = persistentController.container.newBackgroundContext()
    }
    
    // MARK: - UserInformationControllable conformance
    
    func setNewsExpirationDays(_ days: Int) async throws {
        try await backgroundContext.perform {
            guard let userInformation = try? loadCurrentUserInformation()
            else { throw Error.failedToFetch }
            userInformation.newsExpirationDays = days
            do { try backgroundContext.save() }
            catch { throw Error.failedToSet }
        }
    }
    
    /// 현재의 사용자 정보를 불러옵니다.
    /// - Returns: 현재 사용자 정보.
    private func loadCurrentUserInformation() throws -> UserInformation {
        if let existingUserInformation = try? UserInformation.fetchRequest().execute().first {
            return existingUserInformation
        } else {
            return try UserInformation(using: backgroundContext)
        }
    }
    
    // MARK: - Error
    
    /// 사용자 정보를 관리하는데 있어 발생할 수 있는 오류를 정의합니다.
    enum Error: PresentableError {
        /// 사용자 정보를 불러오지 못한 경우.
        case failedToFetch
        /// 사용자 정보를 설정하지 못한 경우.
        case failedToSet
        
        var title: String {
            "사용자 정보 오류"
        }
        
        var description: String {
            switch self {
            case .failedToFetch:
                return "사용자 정보를 불러오는데 실패했습니다."
            case .failedToSet:
                return "사용자 정보를 설정하는데 실패했습니다."
            }
        }
    }
}
