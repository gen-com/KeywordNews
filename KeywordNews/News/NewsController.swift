//
//  NewsController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import CoreData

/// 뉴스 관리자의 구현체입니다.
actor NewsController: NewsControllable {
    var persistentController: Persistable
    var keywordNewsDictionary: [KeywordWrapper: NewsInformationProtocol]
    private let backgroundContext: NSManagedObjectContext
    private var standardDateForOrder: Date
    private var storedKeywordSet: Set<KeywordWrapper>
    
    // MARK: - Initializer
    
    init(persistentController: Persistable) {
        self.persistentController = persistentController
        keywordNewsDictionary = [:]
        backgroundContext = persistentController.container.newBackgroundContext()
        standardDateForOrder = Date()
        storedKeywordSet = []
    }
    
    // MARK: - NewsControllable conformance
    
    func setStoredKeywords(_ keywords: [some KeywordProtocol]) async {
        storedKeywordSet = Set(keywords.map { KeywordWrapper.content($0) })
        for keyword in keywords {
            var lastSavedNewsDate: Date?
            await backgroundContext.perform {
                lastSavedNewsDate = try? News.fetchRequest(for: keyword, amount: 1).execute().first?.order
            }
            keywordNewsDictionary[.content(keyword)] = NewsInformation(
                keyword: keyword,
                lastSavedNewsDate: lastSavedNewsDate
            )
        }
    }
    
    func fetchNews(
        for keyword: some KeywordProtocol,
        withSession session: URLSession,
        archiveFilter: Bool = false
    ) async throws {
        guard var newsInformation = newsInforamtionToFetch(for: keyword) else { return }
        if newsInformation.isSearchAvailable {
            do {
                let newsSearchResult = try await searchNews(with: newsInformation, andSession: session)
                try await update(&newsInformation, with: newsSearchResult)
            } catch {
                newsInformation.isFetching = false
                throw error
            }
        }
        if storedKeywordSet.contains(.content(keyword)) {
            await fetchFromStore(to: &newsInformation)
        }
        newsInformation.isFetching = false
        keywordNewsDictionary[.content(keyword)] = newsInformation
    }
    
    func refreshNews(for keyword: some KeywordProtocol, withSession session: URLSession) async throws {
        guard var newsInformation = keywordNewsDictionary[.content(keyword)] else { return }
        newsInformation.nextNewsSearchPosition = 1
        newsInformation.lastSavedNewsDate = newsInformation.newsList.first?.order
        newsInformation.isSearchAvailable = true
        newsInformation.didFetchAll = false
        newsInformation.removeAllNews()
        keywordNewsDictionary[.content(keyword)] = newsInformation
        standardDateForOrder = Date()
        try await fetchNews(for: keyword, withSession: session)
    }
    
    func addNews(for keyword: some KeywordProtocol) async throws {
        guard let newsInformation = keywordNewsDictionary[.content(keyword)] else { return }
        try await save(newsInformation.newsList, referringTo: newsInformation)
        storedKeywordSet.insert(.content(keyword))
    }
    
    func removeNews(for keyword: some KeywordProtocol) async throws {
        try await removeNews(for: News.fetchRequest(for: keyword))
        keywordNewsDictionary.removeValue(forKey: .content(keyword))
    }
    
    func removeNews(orderThanOrEqual date: Date) async throws {
        try await removeNews(for: News.fetchRequest(orderThanOrEqual: date))
    }
    
    func changeArchiveState(of news: some NewsProtocol) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let weakSelf = self,
                  let targetNews = try? News.fetchRequest(forCorresponding: news.link).execute().first
            else { throw Error.failToChangeArchiveState }
            targetNews.isArchived.toggle()
            do { try weakSelf.backgroundContext.save() }
            catch { throw Error.failToChangeArchiveState }
        }
    }
    
    // MARK: - Methods to help manage news
    
    /// 뉴스를 가져오기 위한 뉴스 정보를 불러옵니다.
    ///
    /// 가져오려는 뉴스 정보가 현재 요청중이면 반환하지 않습니다.
    /// - Parameter keyword: 키워드.
    /// - Returns: 뉴스 정보.
    private func newsInforamtionToFetch(for keyword: some KeywordProtocol) -> NewsInformationProtocol? {
        var newsInformation = keywordNewsDictionary[.content(keyword)] ?? NewsInformation(keyword: keyword)
        guard newsInformation.isFetching == false else { return nil }
        newsInformation.isFetching = true
        return newsInformation
    }
    
    /// 뉴스 정보를 통해 검색을 수행합니다.
    /// - Parameters:
    ///   - newsInformation: 요청을 위한 뉴스 정보.
    ///   - session: 요청 세션.
    /// - Returns: 뉴스 검색 결과.
    private func searchNews(
        with newsInformation: some NewsInformationProtocol,
        andSession session: URLSession
    ) async throws -> NewsSearchResult {
        let parameter = NaverSearcher.NewsParameter(
            keyword: newsInformation.keyword.value,
            itemStartPoint: newsInformation.nextNewsSearchPosition,
            itemAmount: Constant.fetchAmount
        )
        return try await NaverSearcher.search(for: .news, with: parameter, andSession: session)
    }
    
    /// 뉴스 검색 결과로 뉴스 정보를 최신화합니다.
    /// - Parameters:
    ///   - newsInformation: 최신화할 뉴스 정보.
    ///   - newsSearchResult: 뉴스 검색 결과.
    private func update(
        _ newsInformation: inout some NewsInformationProtocol,
        with newsSearchResult: NewsSearchResult
    ) async throws {
        let searchLimit = min(Constant.searchLimit, newsSearchResult.totalResult)
        let nextNewsSearchPosition = newsSearchResult.itemStartIndex + newsSearchResult.itemAmount
        newsInformation.nextNewsSearchPosition = nextNewsSearchPosition
        if storedKeywordSet.contains(.content(newsInformation.keyword)) {
            let (noDuplicates, duplicates) = await verifyDuplicates(of: newsSearchResult.items)
            newsInformation.isSearchAvailable = verifyAdditionalSearcheAvailable(
                with: newsInformation,
                duplicates: duplicates,
                and: searchLimit
            )
            try await save(noDuplicates, referringTo: newsInformation)
        } else {
            newsInformation.isSearchAvailable = nextNewsSearchPosition < searchLimit
            newsInformation.didFetchAll = searchLimit <= nextNewsSearchPosition
            newsInformation.append(listOfNews: newsSearchResult.items)
        }
    }
    
    /// 중복된 뉴스가 있는지 확인합니다.
    /// - Parameter newsList: 확인한 뉴스 목록.
    /// - Returns: 중복된 뉴스와 그렇지 않은 뉴스 튜플.
    private func verifyDuplicates(
        of newsList: [some NewsProtocol]
    ) async -> (noDuplicates: [any NewsProtocol], duplicates: [any NewsProtocol]) {
        await backgroundContext.perform {
            var noDuplicates = [any NewsProtocol](), duplicates = [any NewsProtocol]()
            for news in newsList {
                if let fetchedNews = try? News.fetchRequest(forCorresponding: news.link).execute().first {
                    duplicates.append(fetchedNews)
                } else {
                    noDuplicates.append(news)
                }
            }
            return (noDuplicates, duplicates)
        }
    }
    
    /// 뉴스 정보와 중복 뉴스로 추가적인 요청이 가능한지 판별합니다.
    /// - Parameters:
    ///   - newsInformation: 뉴스 정보.
    ///   - duplicates: 중복된 뉴스.
    /// - Returns: 추가적인 요청이 가능한지 여부.
    private func verifyAdditionalSearcheAvailable(
        with newsInformation: any NewsInformationProtocol,
        duplicates: [any NewsProtocol],
        and searchLimit: Int
    ) -> Bool {
        guard let lastSavedNewsDate = newsInformation.lastSavedNewsDate
        else { return newsInformation.nextNewsSearchPosition < searchLimit }
        for news in duplicates where news.order <= lastSavedNewsDate {
            return false
        }
        return newsInformation.nextNewsSearchPosition < searchLimit
    }
    
    /// 뉴스 정보를 참고해서 받은 뉴스를 저장합니다.
    /// - Parameters:
    ///   - newsList: 저장할 뉴스.
    ///   - newsInformation: 저장에 참고할 정보.
    private func save(
        _ newsList: [any NewsProtocol],
        referringTo newsInformation: some NewsInformationProtocol
    ) async throws {
        let standardDateForOrder = standardDateForOrder
        try await backgroundContext.perform { [weak self] in
            guard let weakSelf = self else { throw CustomError.valueNotFound }
            var index = 0
            let newsInsertRequest = NSBatchInsertRequest(entityName: News.entityName, managedObjectHandler: { object in
                if index < newsList.count {
                    guard let news = object as? News else { return true }
                    news.keywordValue = newsInformation.keyword.value
                    news.title = newsList[index].title
                    news.content = newsList[index].content
                    news.link = newsList[index].link
                    news.order = standardDateForOrder.addingTimeInterval(
                        Constant.orderDiff(newsInformation.newsList.count + index)
                    )
                    news.isArchived = false
                    index += 1
                    return false
                }
                return true
            })
            newsInsertRequest.resultType = .statusOnly
            guard let insertResult = try weakSelf.backgroundContext.execute(newsInsertRequest) as? NSBatchInsertResult,
                  let success = insertResult.result as? Bool, success == true
            else { throw Error.failToSave }
        }
    }
    
    /// 저장소에 있는 뉴스를 불러와 뉴스 정보에 반영합니다.
    /// - Parameter newsInformation: 반영할 뉴스 정보.
    private func fetchFromStore(to newsInformation: inout some NewsInformationProtocol) async {
        let keyword = newsInformation.keyword, offset = newsInformation.newsList.count
        let fetchedNews = await backgroundContext.perform {
            try? News.fetchRequest(
                for: keyword,
                amount: Constant.fetchAmount,
                offset: offset
            ).execute()
        } ?? []
        newsInformation.didFetchAll = fetchedNews.isEmpty
        newsInformation.append(listOfNews: fetchedNews)
    }
    
    /// 요청에 해당하는 뉴스를 제거합니다.
    /// - Parameter fetchRequest: 삭제할 뉴스 요청.
    private func removeNews(for fetchRequest: NSFetchRequest<News>) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let weakSelf = self,
                  let fetchRequest = fetchRequest as? NSFetchRequest<NSFetchRequestResult>
            else { throw Error.failToRemove }
            fetchRequest.fetchBatchSize = Constant.batchSize
            let removeRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            removeRequest.resultType = .resultTypeStatusOnly
            guard let result = try? weakSelf.backgroundContext.execute(removeRequest) as? NSBatchDeleteResult,
                  let success = result.result as? Bool, success
            else { throw Error.failToRemove }
        }
    }
    
    // MARK: - Error
    
    enum Error: PresentableError {
        case failToSave
        case failToRemove
        case failToChangeArchiveState
        
        var title: String {
            "키워드 관리"
        }
        
        var description: String {
            switch self {
            case .failToSave:
                return "뉴스를 저장하는데 실패했습니다."
            case .failToRemove:
                return "뉴스를 삭제하는데 실패했습니다."
            case .failToChangeArchiveState:
                return "뉴스 보관 설정에 실패했습니다."
            }
        }
    }
    
    // MARK: - Constant
    
    private enum Constant {
        static let fetchAmount = 10
        static let searchLimit = 100
        static let batchSize = 100
        
        static func orderDiff(_ count: Int) -> TimeInterval {
            -Double(count) * 0.001
        }
    }
}
