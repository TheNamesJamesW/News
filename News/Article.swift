//
//  Article.swift
//  News
//
//  Created by James Wilkinson on 17/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Article: CustomJSONConvertible {
    let source: String // From Feed
    private(set) var headlineList: Set<Feed.HeadlineList>
    let author: String?
    let blurb: String?
    let title: String
    let url: URL
    let imageURL: URL?
    
    let publishDate: Date?
    let fetchedDate: Date
    
    init?(json: JSON, source: String, headlineList: Feed.HeadlineList, fetchedDate: Date) {
        guard let title = json["title"].string,
            let url = URL(string: json["url"].stringValue) else {
                return nil
        }
        
        self.source = source
        self.headlineList = [headlineList]
        self.author = json["author"].string
        self.blurb = json["description"].string
        self.title = title
        self.url = url
        self.imageURL = URL(string: json["urlToImage"].stringValue)
        if let publishDate = json["publishedAt"].double {
            self.publishDate = Date(timeIntervalSince1970: publishDate)
        } else {
            self.publishDate = nil
        }
        self.fetchedDate = fetchedDate
    }
    
    init?(json: JSON) {
        guard let source = json["source"].string,
            let headlineList = json["headlineList"].array?.flatMap({ Feed.HeadlineList(rawValue: $0.stringValue) }),
            !headlineList.isEmpty,
            let title = json["title"].string,
            let url = URL(string: json["url"].stringValue),
            let fetchedDate = json["fetchedDate"].double else {
                return nil
        }
        
        self.source = source
        self.headlineList = Set(headlineList)
        self.author = json["author"].string
        self.blurb = json["description"].string
        self.title = title
        self.url = url
        self.imageURL = URL(string: json["urlToImage"].stringValue)
        if let publishDate = json["publishedAt"].double {
            self.publishDate = Date(timeIntervalSince1970: publishDate)
        } else {
            self.publishDate = nil
        }
        self.fetchedDate = Date(timeIntervalSince1970: fetchedDate)
    }
    
    func toJSON() -> JSON {
        var dict: [String : Any] = [
            "source" : source,
            "headlineList" : headlineList.map { $0.rawValue },
            "title" : title,
            "url" : url.absoluteString,
            "fetchedDate" : fetchedDate.timeIntervalSince1970
        ]
        if let author = author {
            dict["author"] = author
        }
        if let blurb = blurb {
            dict["description"] = blurb
        }
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL.absoluteString
        }
        if let publishDate = publishDate {
            dict["publishDate"] = publishDate.timeIntervalSince1970
        }
        
        return JSON(dict)
    }
}
