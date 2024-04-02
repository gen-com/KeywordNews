//
//  UserInformationController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/16/24.
//

import CoreData

/// 사용자 정보를 관리하는 구현체입니다.
struct UserInformationController: UserInformationControllable {
    private var persistentController: Persistable
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Initializer
    
    init(persistentController: Persistable) {
        self.persistentController = persistentController
        backgroundContext = persistentController.container.newBackgroundContext()
    }
    
    // MARK: - UserInformationControllable conformance
    
    var currentUserInformation: any UserInformationProtocol {
        get async throws {
            try await backgroundContext.perform {
                guard let userInformation = try? UserInformation.fetchRequest().execute().first
                else { throw Error.failedToFetch }
                return FetchedUserInformation(userInformation)
            }
        }
    }
    
    func setNewsExpirationDays(_ days: Int) async throws {
        try await backgroundContext.perform {
            if let userInformation = try? UserInformation.fetchRequest().execute().first {
                userInformation.newsExpirationDays = days
            } else {
                do {
                    let userInformation = try UserInformation(using: backgroundContext)
                    userInformation.newsExpirationDays = days
                } catch { throw Error.failedToCreate }
            }
            do { try backgroundContext.save() }
            catch { throw Error.failedToSet }
        }
    }
    
    // MARK: - Error
    
    /// 사용자 정보를 관리하는데 있어 발생할 수 있는 오류를 정의합니다.
    enum Error: PresentableError {
        /// 사용자 정보를 불러오지 못한 경우.
        case failedToFetch
        /// 키워드 정보를 생성하지 못한 경우.
        case failedToCreate
        /// 사용자 정보를 설정하지 못한 경우.
        case failedToSet
        
        var title: String {
            "사용자 정보 오류"
        }
        
        var description: String {
            switch self {
            case .failedToFetch:
                return "사용자 정보를 불러오는데 실패했습니다."
            case .failedToCreate:
                return "사용자 정보 생성에 실패했습니다."
            case .failedToSet:
                return "사용자 정보를 설정하는데 실패했습니다."
            }
        }
    }
}
