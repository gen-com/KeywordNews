//
//  KeywordController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/2/24.
//

struct KeywordController {
    private let persistenceController: Persistable
    
    // MARK: - Initializer
    
    init(persistenceController: Persistable) {
        self.persistenceController = persistenceController
    }
}
    
// MARK: - KeywordControllable conformance

extension KeywordController: KeywordControllable {
    var currentKeywords: [KeywordProtocol] {
        get async {
            let fetchedKeywords = try? await persistenceController
                .fetch(with: Keyword.fetchRequest())
                .map({ FetchedKeyword($0) })
            return fetchedKeywords ?? []
        }
    }
    
    func add(_ keyword: KeywordProtocol) async throws {
        let order = await currentKeywords.count, amount = 1
        var index = 0
        try await persistenceController.add(Keyword.entityName, amount: amount) { managedObject in
            if index < amount {
                guard let keywordToStore = managedObject as? Keyword else { return true }
                keywordToStore.value = keyword.value
                keywordToStore.order = order
                index += 1
                return false
            }
            return true
        }
    }
    
    func reorder(from source: Int, to destination: Int) async throws {
        let startIndex = min(source, destination), endIndex = max(source, destination)
        let currentKeywords = await currentKeywords
        for order in startIndex...endIndex {
            var propertyToUpdate = [AnyHashable: Any]()
            if order == source {
                propertyToUpdate = [#keyPath(Keyword.order): destination]
            } else {
                propertyToUpdate = [#keyPath(Keyword.order): order + (source < destination ? -1 : 1)]
            }
            try await persistenceController.update(
                Keyword.entityName,
                forMatching: Keyword.predicate(for: currentKeywords[order]),
                with: propertyToUpdate
            )
        }
    }
    
    func remove(_ keyword: KeywordProtocol) async throws {
        let currentKeywords = await currentKeywords
        for order in keyword.order..<currentKeywords.count {
            if order == keyword.order {
                try await persistenceController.remove(with: Keyword.fetchRequest(for: keyword))
            } else {
                try await persistenceController.update(
                    Keyword.entityName,
                    forMatching: Keyword.predicate(for: currentKeywords[order]),
                    with: [#keyPath(Keyword.order): order - 1]
                )
            }
        }
    }
}
