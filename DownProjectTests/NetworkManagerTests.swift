//
//  NetworkManagerTests.swift
//  DownProjectTests
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import XCTest
import Combine
@testable import DownProject

final class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkManager!
    var mockSessionManager: MockURLSessionManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockSessionManager = MockURLSessionManager()
        networkManager = NetworkManager(sessionManager: mockSessionManager)
        cancellables = []
    }

    override func tearDown() {
        networkManager = nil
        mockSessionManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testDownloadJSON_WhenBadUrl() {
        let urlString = ""
     
        let expectation = self.expectation(description: "Download JSON Failure")

        networkManager.downloadJSON(from: urlString)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error,NetworkError.badURL)
                }
                expectation.fulfill()
            }, receiveValue: { data in
                XCTFail("Unexpected data received: \(data)")
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDownloadJSON_WhenUrlSessionFaialed() {
        let urlString = "https://raw.githubusercontent.com/downapp/sample/main/sample.json"
        mockSessionManager.data = nil
        mockSessionManager.error = .requestFailed
        
        let expectation = self.expectation(description: "Download JSON Failure")

        networkManager.downloadJSON(from: urlString)
            .sink(receiveCompletion: { completion in
                if case .failure(.unknown(let error)) = completion {
                    XCTAssertEqual(error as! NetworkError, NetworkError.requestFailed)
                }
                expectation.fulfill()
            }, receiveValue: { data in
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDownloadJSON_Success() {
        let urlString = "https://raw.githubusercontent.com/downapp/sample/main/sample.json"
        let jsonData = """
           {
               "userId": 1,
               "id": 1,
               "title": "delectus aut autem",
               "completed": false
           }
           """.data(using: .utf8)!
        mockSessionManager.data = jsonData
        mockSessionManager.error = nil
        
        let expectation = self.expectation(description: "Download JSON")
        
        networkManager.downloadJSON(from: urlString).sink { completion in
            if case .failure(let error) = completion {
                XCTFail("Error: \(error)")
            }
            expectation.fulfill()
        } receiveValue: { data in
            XCTAssertNotNil(data, "No data was downloaded.")
            expectation.fulfill()
        }.store(in: &cancellables)
        
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchAndDecodeSuccess() {
        struct Todo: Decodable {
            let userId: Int
            let id: Int
            let title: String
            let completed: Bool
        }
        
        let urlString = "https://jsonplaceholder.typicode.com/todos/1"
        let jsonData = """
                {
                    "userId": 1,
                    "id": 1,
                    "title": "delectus aut autem",
                    "completed": false
                }
                """.data(using: .utf8)!
                mockSessionManager.data = jsonData
                mockSessionManager.error = nil
        
        let expectation = self.expectation(description: "Fetch and Decode JSON")
        
        networkManager.fetchAndDecode(from: urlString, as: Todo.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Error: \(error)")
                }
                expectation.fulfill()

            }, receiveValue: { todo in
                XCTAssertEqual(todo.id, 1, "Expected todo id to be 1")
                XCTAssertEqual(todo.userId, 1, "Expected userId to be 1")
                XCTAssertEqual(todo.title, "delectus aut autem", "Expected title to match")
                XCTAssertEqual(todo.completed, false, "Expected completed to be false")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchAndDecodeFailure() {
        struct Todo: Decodable {
            let userId: Int
            let id: Int
            let title: String
            let completed: Bool
        }
        
        let urlString = "https://jsonplaceholder.typicode.com/invalid-endpoint"
        mockSessionManager.error = NetworkError.unknown(URLError(.badServerResponse))
        
        let expectation = self.expectation(description: "Fetch and Decode JSON Failure")
        
        networkManager.fetchAndDecode(from: urlString, as: Todo.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { todo in
                XCTFail("Unexpected data received: \(todo)")
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
