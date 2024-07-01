//
//  MockImageCacheManager.swift
//  DownProjectTests
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation
@testable import DownProject

final class MockImageCacheManager: ImageCacheManagerInterface {
    var data: Data?
    var error: Error?
    
    func downloadAndCacheData(urlString: String) async throws -> Data {
        if let error = error {
            throw error
        }
        return data ?? Data()
    }
    
    func configureCache(countLimit: Int, totalCostLimit: Int) {
        
    }
    
}

