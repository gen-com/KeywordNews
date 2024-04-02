//
//  KeywordController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/2/24.
//

import CoreData

/// 키워드를 관리하는 구현체입니다.
struct KeywordController: KeywordControllable {
    private var persistentController: Persistable
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Initializer
    
    init(persistentController: Persistable) {
        self.persistentController = persistentController
        backgroundContext = persistentController.container.newBackgroundContext()
    }
    
    // MARK: - KeywordControllable conformance
    
    var currentKeywords: [any KeywordProtocol] {
        get async {
            await backgroundContext.perform {
                (try? Keyword.fetchRequest().execute().map { FetchedKeyword($0) }) ?? []
            }
        }
    }
    
    func add(_ keyword: any KeywordProtocol) async throws {
        try await backgroundContext.perform {
            guard let order = try? backgroundContext.count(for: Keyword.fetchRequest())
            else { throw Error.failedToFetch }
            guard let keywordToSave = try? Keyword(using: backgroundContext)
            else { throw Error.failedToCreate }
            keywordToSave.value = keyword.value
            keywordToSave.order = order
            do { try backgroundContext.save() }
            catch { throw Error.failedToAdd }
        }
    }
    
    func remove(_ keyword: any KeywordProtocol) async throws {
        try await backgroundContext.perform {
            guard let storedKeywords = try? Keyword.fetchRequest(from: keyword.order).execute()
            else { throw Error.failedToFetch }
            for storedKeyword in storedKeywords {
                if storedKeyword.value == keyword.value {
                    backgroundContext.delete(storedKeyword)
                } else {
                    storedKeyword.order -= 1
                }
            }
            do { try backgroundContext.save() }
            catch { throw Error.failedToRemove }
        }
    }
    
    func reorder(from source: Int, to destination: Int) async throws {
        try await backgroundContext.perform {
            let startIndex = min(source, destination), endIdnex = max(source, destination)
            guard let storedKeywords = try? Keyword.fetchRequest(from: startIndex, to: endIdnex).execute()
            else { throw Error.failedToFetch }
            for keyword in storedKeywords {
                if keyword.order == source {
                    keyword.order = destination
                } else {
                    keyword.order += (source < destination ? -1 : 1)
                }
            }
            do { try backgroundContext.save() }
            catch { throw Error.failedToEdit }
        }
    }
    
    // MARK: - Error
    
    /// 키워드 정보를 관리하는데 있어 발생할 수 있는 오류를 정의합니다.
    enum Error: PresentableError {
        /// 필요한 키워드 정보를 불러오지 못한 경우.
        case failedToFetch
        /// 키워드 정보를 생성하지 못한 경우.
        case failedToCreate
        /// 키워드 정보를 추가하지 못한 경우.
        case failedToAdd
        /// 키워드 정보를 삭제하지 못한 경우.
        case failedToRemove
        /// 키워드 정보를 수정하지 못한 경우.
        case failedToEdit
        
        var title: String {
            "키워드 정보 오류"
        }
        
        var description: String {
            switch self {
            case .failedToFetch:
                return "필요한 키워드 정보를 불러오는데 실패했습니다."
            case .failedToCreate:
                return "키워드 정보 생성에 실패했습니다."
            case .failedToAdd:
                return "중복 혹은 다른 이유로 키워드 정보 추가에 실패했습니다."
            case .failedToRemove:
                return "키워드 정보 삭제에 실패했습니다."
            case .failedToEdit:
                return "키워드 정보 변경에 실패했습니다."
            }
        }
    }
}
