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
    var profileModels = [ProfileModel]()
    var error: NetworkError?
    var data: Data?
    
    func fetchAndDecode<T>(from urlString: String, as type: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        let subject = PassthroughSubject<T, NetworkError>()
        
            if let error  {
                subject.send(completion: .failure(error))
            } else if !profileModels.isEmpty {
                        subject.send(profileModels as! T)
                        subject.send(completion: .finished)
            }
        
        return subject.eraseToAnyPublisher()
    }

    func downloadJSON(from urlString: String) -> AnyPublisher<Data, NetworkError> {
           let subject = PassthroughSubject<Data, NetworkError>()
           
           DispatchQueue.global().async {
               if let error = self.error {
                   subject.send(completion: .failure(error))
               } else {
                   if let data = self.data {
                       subject.send(data)
                       subject.send(completion: .finished)
                   } else {
                       subject.send(completion: .failure(.unknown(NSError(domain: "No data", code: 0, userInfo: nil))))
                   }
               }
           }
           
           return subject.eraseToAnyPublisher()
       }
}
