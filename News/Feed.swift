//
//  Feed.swift
//  News
//
//  Created by James Wilkinson on 17/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Feed: CustomJSONConvertible {
    enum Category: String {
        case business, entertainment, gaming, general, music, sport, technology
        case scienceAndNature = "science-and-nature"
    }
    
    enum HeadlineList: String {
        case top, latest, popular
    }
    
    enum LogoSize : String {
        case small, medium, large
    }
    
    let id: String
    let name: String
    //    let description: String
    let homePageURL: URL?
    let category: Category
    let headlineList: [HeadlineList]
    //    let language: String
    //    let country: String
    let logoURLs: [LogoSize : URL]
    
    
    init?(json: JSON) {
        guard let id = json["id"].string,
            let name = json["name"].string,
            let category = Category(rawValue: json["category"].stringValue),
            let logoURLs = (json["urlsToLogos"].dictionaryObject as? [String : String])?.flatMapPair({ (LogoSize(rawValue: $0.key), URL(string: $0.value)) }),
            !logoURLs.isEmpty,
            let headlineList = json["sortBysAvailable"].array?.flatMap({ HeadlineList(rawValue: $0.stringValue) }),
            !headlineList.isEmpty
            else { return nil }
        
        self.id = id
        self.name = name
        self.homePageURL = URL(string: json["url"].stringValue)
        self.category = category
        self.logoURLs = logoURLs
        self.headlineList = headlineList
    }
    
    func toJSON() -> JSON {
        let dict: [String : Any] = [
            "id" : id,
            "name" : name,
            "url" : homePageURL?.absoluteString ?? "",
            "category" : category.rawValue,
            "urlsToLogos" : logoURLs.mapPair { ($0.rawValue, $1.absoluteString) },
            "sortBysAvailable" : headlineList.map { $0.rawValue }
        ]
        return JSON(dict)
    }
}
