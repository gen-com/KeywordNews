//
//  UserInformationController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 2/16/24.
//

struct UserInformationController {
    private let persistenceController: Persistable
    
    // MARK: - Initializer
    
    init(persistenceController: Persistable) {
        self.persistenceController = persistenceController
    }
}

// MARK: - UserInformationControllable conformance

extension UserInformationController: UserInformationControllable {
    var currentUserInformation: UserInformationProtocol? {
        get async {
            try? await persistenceController
                .fetch(with: UserInformation.fetchRequest())
                .map({ FetchedUserInformation($0) }).first
        }
    }
    
    func createDefaultUserInformation() async throws {
        let amount = 1
        var index = 0
        try await persistenceController.add(UserInformation.entityName, amount: amount) { managedObject in
            if index < amount {
                guard let userInformation = managedObject as? UserInformation else { return true }
                userInformation.newsExpirationDays = Constant.defaultExpirationDays
                index += 1
                return false
            }
            return true
        }
    }
    
    func setNewsExpirationDays(_ days: Int) async throws {
        try await persistenceController.update(
            UserInformation.entityName,
            forMatching: nil,
            with: [#keyPath(UserInformation.newsExpirationDays): days]
        )
    }
}

// MARK: - Constant

extension UserInformationController {
    private enum Constant {
        static let defaultExpirationDays = 30
    }
}
