//
//  ArticlesDownloader.swift
//  News
//
//  Created by James Wilkinson on 20/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import SwiftyJSON

class ArticlesDownloader: Operation {
    private let feed: Feed
    private let feedURLs: [URL]
    
    private var allArticles = SynchronisedArray<Article>()
    
    init(feed: Feed, completion: @escaping (([Article]) -> ())) {
        self.feed = feed
        self.feedURLs = feed.headlineList.flatMap { URL(string: "https://newsapi.org/v1/articles?source=\(feed.id)&sortBy=\($0.rawValue)&apiKey=d15647d1880641f6a214595d209df97e") }
        
        super.init()
        
        self.completionBlock = {
            let sortedByURL = self.allArticles.array.sorted {
                $0.url.absoluteString < $1.url.absoluteString
            }
            let merged = sortedByURL.reduce([Article]()) { (result, next) in
                guard let previous = result.last, previous.url == next.url else {
                    return result + [next]
                }
                let merged = previous.addingHeadlines(next.headlineList)
                return Array(result.dropLast()) + [merged]
            }
            self.allArticles.array = merged
            completion(merged)
        }
    }
    
    override func main() {
        feedURLs.forEach { (url) in
            URLSession.GETSync(url: url) { (data, _) in
                guard let data = data else { return }
                
                let json = JSON(data: data)
                guard let articlesJSON = json["articles"].array, let source = json["source"].string, let headlineList = Feed.HeadlineList(rawValue: json["sortBy"].stringValue) else { return }
                
                print(url)
                
                let articles = articlesJSON.flatMap { Article(json: $0, source: source, headlineList: headlineList, fetchedDate: Date()) }
                self.allArticles.append(contentsOf: articles)
            }
        }
    }
}
