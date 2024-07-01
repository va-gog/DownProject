//
//  MockNetworkManager.swift
//  DownProjectTests
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Combine
import Foundation
@testable import DownProject

final class MockNetworkManager: NetworkManagerProtocol {
    var data: Data?
    var error: NetworkError?
    
    func fetchAndDecode<T>(from urlString: String, as type: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        let subject = PassthroughSubject<T, NetworkError>()
        
        DispatchQueue.global().async {
            if let error = self.error {
                subject.send(completion: .failure(error))
            } else {
                if let data = self.data {
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        subject.send(decodedData)
                        subject.send(completion: .finished)
                    } catch {
                        subject.send(completion: .failure(.decodingFailed))
                    }
                }
            }
        }
        
        return subject.eraseToAnyPublisher()
    }

    
}
