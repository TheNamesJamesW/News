//
//  StateController.swift
//  News
//
//  Created by James Wilkinson on 20/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation
import SwiftyJSON

class StateController {
    static let instance = StateController()
    
    enum State: Int {
        case latest
        case readLater
        case discarded
    }
    
    enum Event {
        case error(Error?)
        case preloaded([Article])
        case downloading
        case loaded([Article])
    }
    
    typealias Handler = (Event) -> ()
    private var handlers = [State: [Handler]]()
    
    private(set) var articles = [State : [Article]]()
    
    private let operationQueue: OperationQueue = {
        let op = OperationQueue()
        op.qualityOfService = .userInitiated
        op.maxConcurrentOperationCount = 10
        return op
    }()
    
    private(set) var isDownloading = false
    
    private init() { }
    
    // MARK: - Event subscription
    /// Best to use [weak/unowned self] capture list
    func subscribe(to state: State, withHandler handler: @escaping Handler) {
        guard let _ = handlers[state] else {
            handlers[state] = [handler]
            return
        }
        handlers[state]!.append(handler)
    }
    
    private func fire(_ event: Event, for state: State) {
        for handler in handlers[state] ?? [] {
            handler(event)
        }
    }
    
    // MARK: - Feed Article fetching
    func downloadFeedArticles() {
        guard !isDownloading else { return }
        let feedURL = URL(string: "https://newsapi.org/v1/sources")!
        URLSession.newsDefault.downloadString(feedURL, errorHandler: {
            // TODO: Fire ErrorHandler for .latest
            print("Could not download from \(feedURL): \($0)")
        }, successHandler: {
            guard let sources = JSON.parse($0)["sources"].array else {
                // TODO: Fire ErrorHandler for .latest
                print("Error parsing \(feedURL)")
                return
            }
            let feeds = sources.flatMap { Feed(json: $0) }
            JSONFlatFile.default["feeds"] = JSON(feeds.map { $0.toJSON() })
            
            self.downloadArticles(for: feeds)
        })
    }
    
    private func downloadArticles(for feeds: [Feed]) {
        let arts = JSONFlatFile.default["latestArticles"]?.array?.flatMap { Article(json: $0) } ?? []
        set(arts, for: .latest)
        fire(.preloaded(arts), for: .latest)
        
        fire(.downloading, for: .latest)
        
        let syncArticles = SynchronisedArray(arts)
        
        let operations = feeds.map({ ArticlesDownloader(feed: $0, completion: {
            if $0.isEmpty {
                
            }
            syncArticles.append(contentsOf: $0)
        })
        })
        
        operationQueue.addOperations(operations, waitUntilFinished: true)
        set(syncArticles.array, for: .latest)
        fire(.loaded(syncArticles.array), for: .latest)
    }
    
    func readLater(_ article: Article) {
        var articles = get(for: .latest)
        guard let index = articles.index(where: { $0.url == article.url }) else { return }
        articles.remove(at: index)
        set(articles, for: .latest)
        
        let saved = get(for: .readLater)
        set(saved + [article], for: .readLater)
    }
    
    func discard(_ article: Article, for state: State) {
        guard state != .discarded else { return }
        
        var articles = get(for: state)
        guard let index = articles.index(where: { $0.url == article.url }) else { return }
        articles.remove(at: index)
        set(articles, for: state)
    }
    
    private func set(_ articles: [Article], for state: State) {
        let sortedByURL = articles.sorted {
            $0.url.absoluteString < $1.url.absoluteString
        }
        let merged = sortedByURL.reduce([Article]()) { (result, next) in
            guard let previous = result.last, previous.url == next.url else {
                return result + [next]
            }
            let merged = previous.addingHeadlines(next.headlineList)
            return Array(result.dropLast()) + [merged]
        }
        
        let articles: [Article]
        switch state {
        case .latest:
            let discardedURLs = get(for: .discarded).map { $0.url }
            articles = merged.filter { !discardedURLs.contains($0.url) }
        case .readLater:
            articles = merged
        case .discarded:
            articles = merged.flatMap { $0.stripped() }
        }
        
//        JSONFlatFile.default[.latest] = JSON(articles.map { $0.toJSON() })
        self.articles[state] = articles
    }
    
    private func get(for state: State) -> [Article] {
        return self.articles[state] ?? []
    }
}

extension JSONFlatFile {
    subscript(_ state: StateController.State) -> JSON? {
        get {
            switch state {
            case .latest:
                return self["latestArticles"]
            case .readLater:
                return self["savedArticles"]
            case .discarded:
                return self["discardedArticles"]
            }
        }
        set {
            switch state {
            case .latest:
                self["latestArticles"] = newValue
            case .readLater:
                self["savedArticles"] = newValue
            case .discarded:
                self["discardedArticles"] = newValue
            }
        }
    }
}
