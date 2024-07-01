//
//  ImageCacheManager.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

struct ImageCacheManager: ImageCacheManagerInterface {
    private let cache: NSCache<NSString, NSData>
    private let sessionManager: URLSessionManagerProtocol

    init(cache: NSCache<NSString, NSData>, sessionManager: URLSessionManagerProtocol = URLSessionManager()) {
        self.cache = cache
        self.sessionManager = sessionManager
    }
    
    func configureCache(countLimit: Int, totalCostLimit: Int) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }
    
    func downloadAndCacheData(urlString: String) async throws -> Data {
        let cacheKey = NSString(string: urlString)
        
        if let cachedData = cache.object(forKey: cacheKey) {
            return cachedData as Data
        }
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await sessionManager.dataFrom(url: url)
        
        self.cache.setObject(data as NSData, forKey: cacheKey)
        
        return data
    }
}
