//
//  NewsController.swift
//  KeywordNews
//
//  Created by Byeongjo Koo on 3/14/24.
//

import CoreData

/// 뉴스를 관리자 프로토콜의 별칭입니다.
typealias NewsControllable = any SearchItemControllable<NewsProtocol>

final class NewsController {
    private let persistenceController: Persistable
    private let memoryAccessQueue = DispatchQueue(label: Constant.memoryAccessQueueLabel)
    private var fetchingKeywordSet = Set<String>()
    private var standardDateForOrder = Date()
    
    // MARK: - Initializer
    
    init(persistenceController: Persistable) {
        self.persistenceController = persistenceController
    }
}
    
// MARK: - NewsControllable conformance

extension NewsController: SearchItemControllable {
    func setLastSavedItemDate(for newsInformation: inout NewsInformationProtocol) async {
        let fetchRequest = News.fetchRequest(for: newsInformation.keyword, amount: 1)
        if let lastStoredNewsDate = try? await persistenceController.fetch(with: fetchRequest).first?.order {
            newsInformation.setLastStoredNewsDate(as: lastStoredNewsDate)
        }
    }
    
    func fetchItems(for newsInformation: inout NewsInformationProtocol, withSession session: URLSession) async throws {
        guard setFetchingState(for: newsInformation.keyword, as: .fetching) else { throw Error.alreadyInProgress }
        newsInformation.setFetchState(as: .fetching)
        var fetchResult = NewsFetchResult()
        if newsInformation.isSearchAvailable, newsInformation.archiveFlag == false {
            let newsSearchResult = try await searchNews(referringTo: newsInformation, withSession: session)
            fetchResult.update(referringTo: newsSearchResult)
            if newsInformation.keyword.isSaved {
                let (noDuplicates, duplicates) = await verifyDuplicates(of: newsSearchResult.items)
                let doesOverlapSavedItems = does(duplicates, overlaps: newsInformation.lastStoredNewsDate)
                fetchResult.setDoesOverlapSavedItems(as: doesOverlapSavedItems)
                try await save(noDuplicates, referringTo: newsInformation)
            } else {
                fetchResult.items = newsSearchResult.items
            }
        }
        if newsInformation.keyword.isSaved {
            fetchResult.items = await fetchNewsFromStore(referringTo: newsInformation)
        }
        update(&newsInformation, basedOn: fetchResult)
        setFetchingState(for: newsInformation.keyword, as: .idle)
    }
    
    func refreshItems(
        for newsInformation: inout NewsInformationProtocol,
        withSession session: URLSession
    ) async throws {
        standardDateForOrder = Date()
        newsInformation.refresh()
        try await fetchItems(for: &newsInformation, withSession: session)
    }
    
    func saveItems(of newsInformation: inout NewsInformationProtocol) async throws {
        try await save(newsInformation.items, referringTo: newsInformation)
    }
    
    func removeItems(orderThanOrEqual date: Date) async throws {
        try await persistenceController.remove(with: News.fetchRequest(orderThanOrEqual: date))
    }
    
    func setArchiveState(
        of news: NewsProtocol,
        as state: Bool,
        from newsInformation: inout NewsInformationProtocol
    ) async throws {
        try await persistenceController.update(
            News.entityName,
            forMatching: News.predicate(for: news.link),
            with: [#keyPath(News.isArchived): state]
        )
        try newsInformation.setArchiveState(of: news, as: state)
    }
}

// MARK: - Methods to help control news

extension NewsController {
    /// 키워드에 대해 요청 상태를 설정합니다.
    /// - Parameters:
    ///   - keyword: 대상 키워드.
    ///   - state: 설정할 상태.
    /// - Returns: 성공 여부.
    @discardableResult
    private func setFetchingState(for keyword: KeywordProtocol, as state: FetchState) -> Bool {
        var didSuccess = false
        memoryAccessQueue.sync { [unowned self] in
            switch state {
            case .idle:
                if let _ = fetchingKeywordSet.remove(keyword.value) {
                    didSuccess = true
                }
            case .fetching:
                let (inserted, _) = fetchingKeywordSet.insert(keyword.value)
                didSuccess = inserted
            }
        }
        return didSuccess
    }
    
    /// 뉴스 정보를 통해 검색을 수행합니다.
    /// - Parameters:
    ///   - newsInformation: 뉴스 정보.
    ///   - session: 요청 세션.
    /// - Returns: 뉴스 검색 결과.
    private func searchNews(
        referringTo newsInformation: NewsInformationProtocol,
        withSession session: URLSession
    ) async throws -> NewsSearchResult {
        let parameter = NaverSearcher.NewsParameter(
            keyword: newsInformation.keyword.value,
            itemStartPoint: newsInformation.nextNewsSearchPosition,
            itemAmount: Constant.fetchAmount
        )
        return try await NaverSearcher.search(for: .news, with: parameter, andSession: session)
    }
    
    /// 중복된 뉴스가 있는지 확인합니다.
    /// - Parameter newsList: 확인한 뉴스 목록.
    /// - Returns: 중복된 뉴스와 그렇지 않은 뉴스 튜플.
    private func verifyDuplicates(
        of newsList: [NewsProtocol]
    ) async -> (noDuplicates: [NewsProtocol], duplicates: [NewsProtocol]) {
        var noDuplicates = [NewsProtocol](), duplicates = [NewsProtocol]()
        for news in newsList {
            let fetchRequest = News.fetchRequest(forCorresponding: news.link)
            if let fetchedNews = try? await persistenceController.fetch(with: fetchRequest).first {
                duplicates.append(fetchedNews)
            } else {
                noDuplicates.append(news)
            }
        }
        return (noDuplicates, duplicates)
    }
    
    /// 뉴스 정보와 중복 뉴스로 추가적인 요청이 가능한지 판별합니다.
    /// - Parameters:
    ///   - duplicates: 중복된 뉴스.
    ///   - lastSavedNewsDate: 저장한 뉴스 중 가장 최신 뉴스의 순서 날짜.
    /// - Returns: 겹치는지 여부.
    private func does(_ duplicates: [NewsProtocol], overlaps lastSavedNewsDate: Date?) -> Bool {
        if let lastSavedNewsDate {
            for news in duplicates where news.order <= lastSavedNewsDate {
                return true
            }
        }
        return false
    }
    
    /// 뉴스 정보를 참고해서 받은 뉴스를 저장합니다.
    /// - Parameters:
    ///   - newsList: 저장할 뉴스.
    ///   - newsInformation: 참고할 뉴스 정보.
    private func save(_ newsList: [NewsProtocol], referringTo newsInformation: NewsInformationProtocol) async throws {
        let standardDateForOrder = standardDateForOrder
        let newsCount = newsInformation.items.count
        var index = 0
        try await persistenceController.add(News.entityName, amount: newsList.count) { managedObject in
            if index < newsList.count {
                guard let news = managedObject as? News else { return true }
                news.keywordValue = newsInformation.keyword.value
                news.title = newsList[index].title
                news.content = newsList[index].content
                news.link = newsList[index].link
                news.order = standardDateForOrder.addingTimeInterval(Constant.orderDiff(newsCount + index))
                news.isArchived = false
                index += 1
                return false
            }
            return true
        }
    }
    
    /// 저장소에 있는 뉴스를 불러옵니다.
    /// - Parameter newsInformation: 참고할 뉴스 정보.
    /// - Returns: 저장소에서 가져온 뉴스 목록.
    private func fetchNewsFromStore(referringTo newsInformation: NewsInformationProtocol) async -> [NewsProtocol] {
        let keyword = newsInformation.keyword, offset = newsInformation.items.count
        let fetchRequest = News.fetchRequest(
            for: keyword,
            amount: Constant.fetchAmount,
            offset: offset,
            archiveFilter: newsInformation.archiveFlag
        )
        let fetchNewsList = try? await persistenceController.fetch(with: fetchRequest).map { FetchedNews($0) }
        return fetchNewsList ?? []
    }
    
    /// 인자로 받은 뉴스 정보를 가져오기 결과를 바탕으로 "단일 메모리 접근으로" 최신화합니다.
    /// - Parameters:
    ///   - newsInformation: 최신화할 뉴스 정보.
    ///   - fetchResult: 가져오기 검색 결과.
    private func update(_ newsInformation: inout NewsInformationProtocol, basedOn fetchResult: NewsFetchResult) {
        memoryAccessQueue.sync {
            newsInformation.update(basedOn: fetchResult)
            newsInformation.setFetchState(as: .idle)
        }
    }
}
    
// MARK: - Error
    
extension NewsController {
    enum Error: PresentableError {
        case alreadyInProgress
        
        var title: String {
            "뉴스 관리 오류"
        }
        
        var description: String {
            switch self {
            case .alreadyInProgress:
                return "이미 진행중인 요청입니다."
            }
        }
    }
}
    
// MARK: - Constants

extension NewsController {
    private enum Constant {
        static let fetchAmount = 10
        static let batchSize = 100
        
        static let memoryAccessQueueLabel = "memoryAccessQueue"
        
        static func orderDiff(_ count: Int) -> TimeInterval {
            -Double(count) * 0.001
        }
    }
}
