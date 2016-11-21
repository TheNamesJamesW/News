//
//  File.swift
//  News
//
//  Created by James Wilkinson on 20/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

fileprivate var loaded = false
fileprivate let session: URLSession = {
    defer {
        loaded = true
    }
    if loaded {
        assertionFailure()
    }
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 3
    config.timeoutIntervalForResource = 6
    config.urlCache = nil
    
    // set up and start the downloader
    let session = URLSession(configuration: config)
    return session
}()

extension URLSession {
    static var newsDefault: URLSession {
        return .shared
    }
    
    @discardableResult
    class func GETSync(url: URL, completion: @escaping ((Foundation.Data?, Error?) -> Void)) -> URLSessionDataTask? {
        let request = URLRequest(url: url)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            completion(data, error)
            
            semaphore.signal()
        }
        dataTask.resume()
        
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return dataTask
    }
    
    func download<T>(_ url: URL, errorHandler: @escaping (Error?) -> (), parse: @escaping (Data) -> T?, successHandler: @escaping (T) -> ()) {
        let session = self.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else { errorHandler(error); return }
            guard let result = parse(data) else { errorHandler(nil); return }
            successHandler(result)
        }
        session.resume()
    }
    
    func downloadSync<T>(_ url: URL, errorHandler: @escaping (Error?) -> (), parse: @escaping (Data) -> T?, successHandler: @escaping (T) -> ()) {
        let semaphore = DispatchSemaphore(value: 0)
        
//        self.download(url, errorHandler: {
//            semaphore.signal()
//            errorHandler($0)
//        }, parse: parse, successHandler: {
//            semaphore.signal()
//            successHandler($0)
//        })
        let session = self.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else { errorHandler(error); semaphore.signal(); return }
            guard let result = parse(data) else { errorHandler(nil); semaphore.signal(); return }
            successHandler(result)
            semaphore.signal();
        }
        session.resume()

        
        if case DispatchTimeoutResult.timedOut = semaphore.wait(timeout: DispatchTime.now() + .seconds(10)) {
            errorHandler(nil)
        }
        
    }
    
    func downloadString(_ url: URL, errorHandler: @escaping (Error?) -> (), successHandler: @escaping (String) -> ()) {
        let parse: (Data) -> String? = {
            String(data: $0, encoding: .utf8)
        }
        self.download(url, errorHandler: errorHandler, parse: parse, successHandler: successHandler)
    }
    
    func downloadImage(_ url: URL, errorHandler: @escaping (Error?) -> (), successHandler: @escaping (UIImage) -> ()) {
        let parse: (Data) -> UIImage? = {
            UIImage(data: $0)
        }
        self.download(url, errorHandler: errorHandler, parse: parse, successHandler: successHandler)
    }
}

