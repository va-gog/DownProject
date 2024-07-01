//
//  CahcheManagerTests.swift
//  DownProjectTests
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import XCTest
@testable import DownProject

final class ImageCacheManagerTests: XCTestCase {
    var imageCacheManager: ImageCacheManager!
    var mockCache: NSCache<NSString, NSData>!
    var mockSessionManager: MockURLSessionManager!

    override func setUp() {
        super.setUp()
        mockCache = NSCache<NSString, NSData>()
        mockSessionManager = MockURLSessionManager()
        imageCacheManager = ImageCacheManager(cache: mockCache, sessionManager: mockSessionManager)
    }

    override func tearDown() {
        imageCacheManager = nil
        mockCache = nil
        mockSessionManager = nil
        super.tearDown()
    }

    func testDownloadAndCacheData_ReturnsCachedData() async throws {
        let urlString = "https://example.com/image.jpg"
        let expectedData = "Cached Image Data".data(using: .utf8)!
        mockCache.setObject(expectedData as NSData, forKey: NSString(string: urlString))
        
        let data = try await imageCacheManager.downloadAndCacheData(urlString: urlString)
        
        XCTAssertEqual(data, expectedData, "Returned data should be equal to the cached data.")
    }

    func testDownloadAndCacheData_DownloadsAndCachesData() async throws {
        let urlString = "https://example.com/image.jpg"
        let expectedData = "Downloaded Image Data".data(using: .utf8)!
        mockSessionManager.data = expectedData
        
        let data = try await imageCacheManager.downloadAndCacheData(urlString: urlString)
        
        XCTAssertEqual(data, expectedData, "Returned data should be equal to the downloaded data.")
        XCTAssertEqual(mockCache.object(forKey: NSString(string: urlString)) as Data?, expectedData, "Cached data should be equal to the downloaded data.")
    }
    
    func testDownloadAndCacheData_InvalidURL() async {
        let urlString = ""
        
        do {
            _ = try await imageCacheManager.downloadAndCacheData(urlString: urlString)
            XCTFail("Expected to throw an error for invalid URL")
        } catch {
            // Success
        }
    }
}
