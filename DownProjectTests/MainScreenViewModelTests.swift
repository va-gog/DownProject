//
//  MainScreenViewModelTests.swift
//  DownProjectTests
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import XCTest
import Combine
@testable import DownProject

final class MainScreenViewModelTests: XCTestCase {
    var viewModel: MainScreenViewModel!
    var mockCacheManager: MockImageCacheManager!
    var mockNetworkManager: MockNetworkManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCacheManager = MockImageCacheManager()
        mockNetworkManager = MockNetworkManager()
        viewModel = MainScreenViewModel(cacheManager: mockCacheManager, networkManager: mockNetworkManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockCacheManager = nil
        mockNetworkManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testDownloadProfiles_Success() async {
        let urlString = "https://example.com/profiles"
        let expectedProfiles = [
            ProfileModel(userId: 1, name: "Test", age: 1, profilePicUrl: "img")
        ]
        mockNetworkManager.profileModels = expectedProfiles
        
        await viewModel.downloadProfiles(urlString: urlString)
        
        XCTAssertEqual(viewModel.downloadState, .finished, "Download state should be finished")
    }

    func testDownloadProfiles_Failure() async {
        let urlString = "https://example.com/profiles"
        mockNetworkManager.error = .requestFailed
        
        await viewModel.downloadProfiles(urlString: urlString)
        
        XCTAssertEqual(viewModel.downloadState, .failed(.requestFailed), "Download state should be failed with requestFailed error")
    }

    func testLoadProfileImage_Success() async throws {
        let urlString = "https://example.com/image.jpg"
        let expectedData = "Image Data".data(using: .utf8)!
        mockCacheManager.data = expectedData
        
        let data = try await viewModel.loadProfileImage(urlString: urlString)
        
        XCTAssertEqual(data, expectedData, "Returned data should be equal to the expected data")
    }

    func testLoadProfileImage_Failure() async {
        let urlString = "https://example.com/image.jpg"
        mockCacheManager.error = NSError(domain: "Test", code: 0, userInfo: nil)
        
        do {
            _ = try await viewModel.loadProfileImage(urlString: urlString)
            XCTFail("Expected to throw an error when loading profile image")
        } catch {
            // Success
        }
    }

    func testShouldSelectFilter() {
        viewModel.selectedFilterIndex = 0
        XCTAssertTrue(viewModel.shouldSelectFilter(at: 1), "Should be able to select filter at index 1")
        XCTAssertFalse(viewModel.shouldSelectFilter(at: 0), "Should not be able to select filter at the same index")
    }

    func testFilterSelected() {
        viewModel.filterSelected(at: 1)
        XCTAssertEqual(viewModel.selectedFilterIndex, 1, "Selected filter index should be updated")
    }
}
