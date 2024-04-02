//
//  NewsController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import CoreData

/// 뉴스 관리자의 구현체입니다.
actor NewsController: NewsControllable {
    var information: NewsInformationProtocol
    
    private let persistentController: Persistable
    private let backgroundContext: NSManagedObjectContext
    private var standardDateForOrder: Date
    private var lastSavedNewsDate: Date?
    
    // MARK: - Initializer
    
    init(persistentController: Persistable, keyword: any KeywordProtocol) {
        self.persistentController = persistentController
        backgroundContext = persistentController.container.newBackgroundContext()
        standardDateForOrder = Date()
        information = NewsInformation(keyword: keyword)
        Task {
            await setLastSavedNewsDate()
        }
    }
    
    // MARK: - NewsControllable conformance
    
    func setFetchState(as value: Bool) {
        information.setFetchingState(as: value)
    }
    
    func fetchNews(withSession session: URLSession) async throws {
        var fetchResult = NewsFetchResult()
        if information.isSearchAvailable {
            let newsSearchResult = try await searchNews(withSession: session)
            fetchResult.setSearchLimit(newsSearchResult.totalItemAmount)
            fetchResult.searchPosition = newsSearchResult.startIndex
            if information.keyword.isSaved {
                let (noDuplicates, duplicates) = await verifyDuplicates(of: newsSearchResult.items)
                fetchResult.doesOverlapSavedNews = doesOverlapSavedNews(with: duplicates)
                try await save(noDuplicates)
            } else {
                fetchResult.newsList = newsSearchResult.items
            }
        }
        if information.keyword.isSaved {
            fetchResult.newsList = await fetchNewsFromStore()
        }
        information.update(basedOn: fetchResult)
    }
    
    func refreshNews(withSession session: URLSession) async throws {
        standardDateForOrder = Date()
        lastSavedNewsDate = information.newsList.first?.order
        information.refresh()
        try await fetchNews(withSession: session)
    }
    
    func saveNews() async throws {
        try await save(information.newsList)
    }
    
    func removeNews() async throws {
        try await removeNews(for: News.fetchRequest(for: information.keyword))
        information.removeAllNews()
    }
    
    func removeNews(orderThanOrEqual date: Date) async throws {
        try await removeNews(for: News.fetchRequest(orderThanOrEqual: date))
    }
    
    func changeArchiveState(of news: any NewsProtocol) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let weakSelf = self,
                  let targetNews = try? News.fetchRequest(forCorresponding: news.link).execute().first
            else { throw Error.failToChangeArchiveState }
            targetNews.isArchived.toggle()
            do { try weakSelf.backgroundContext.save() }
            catch { throw Error.failToChangeArchiveState }
        }
        try information.changeArchiveState(of: news)
    }
    
    // MARK: - Methods to help control news
    
    private func setLastSavedNewsDate() {
        let keyword = information.keyword
        var lastSavedNews: (any NewsProtocol)?
        backgroundContext.performAndWait {
            lastSavedNews = try? News.fetchRequest(for: keyword, amount: 1).execute().first
        }
        lastSavedNewsDate = lastSavedNews?.order
    }
    
    /// 뉴스 정보를 통해 검색을 수행합니다.
    /// - Parameter session: 요청 세션.
    /// - Returns: 뉴스 검색 결과.
    private func searchNews(withSession session: URLSession) async throws -> NewsSearchResult {
        let parameter = NaverSearcher.NewsParameter(
            keyword: information.keyword.value,
            itemStartPoint: information.nextNewsSearchPosition,
            itemAmount: Constant.fetchAmount
        )
        return try await NaverSearcher.search(for: .news, with: parameter, andSession: session)
    }
    
    /// 중복된 뉴스가 있는지 확인합니다.
    /// - Parameter newsList: 확인한 뉴스 목록.
    /// - Returns: 중복된 뉴스와 그렇지 않은 뉴스 튜플.
    private func verifyDuplicates(
        of newsList: [any NewsProtocol]
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
    /// - Parameter duplicates: 중복된 뉴스.
    private func doesOverlapSavedNews(with duplicates: [any NewsProtocol]) -> Bool {
        if let lastSavedNewsDate {
            for news in duplicates where news.order <= lastSavedNewsDate {
                return true
            }
        }
        return false
    }
    
    /// 뉴스 정보를 참고해서 받은 뉴스를 저장합니다.
    /// - Parameter newsList: 저장할 뉴스.
    private func save(_ newsList: [any NewsProtocol]) async throws {
        let keyword = information.keyword
        let standardDateForOrder = standardDateForOrder
        let newsCount = information.newsList.count
        try await backgroundContext.perform { [weak self] in
            guard let weakSelf = self else { throw CommonError.valueNotFound }
            var index = 0
            let newsInsertRequest = NSBatchInsertRequest(entityName: News.entityName, managedObjectHandler: { object in
                if index < newsList.count {
                    guard let news = object as? News else { return true }
                    news.keywordValue = keyword.value
                    news.title = newsList[index].title
                    news.content = newsList[index].content
                    news.link = newsList[index].link
                    news.order = standardDateForOrder.addingTimeInterval(Constant.orderDiff(newsCount + index))
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
    private func fetchNewsFromStore() async -> [any NewsProtocol] {
        let keyword = information.keyword, offset = information.newsList.count
        let fetchedNews = await backgroundContext.perform {
            try? News.fetchRequest(
                for: keyword,
                amount: Constant.fetchAmount,
                offset: offset
            ).execute().map { FetchedNews($0) }
        }
        return fetchedNews ?? []
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
        case alreadyInProgress
        case failToSave
        case failToRemove
        case failToChangeArchiveState
        
        var title: String {
            "키워드 관리"
        }
        
        var description: String {
            switch self {
            case .alreadyInProgress:
                return "이미 진행중인 수행입니다."
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
        static let batchSize = 100
        
        static func orderDiff(_ count: Int) -> TimeInterval {
            -Double(count) * 0.001
        }
    }
}
