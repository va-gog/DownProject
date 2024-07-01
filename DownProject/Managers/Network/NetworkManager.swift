//
//  NetworkManager.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation
import Combine

protocol URLSessionManagerProtocol {
    func dataTaskPublisher(url: URL) -> AnyPublisher<Data, Error>
    func dataFrom(url: URL) async throws -> (Data, URLResponse)

}

struct URLSessionManager: URLSessionManagerProtocol {
    func dataTaskPublisher(url: URL) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
           .map { $0.data }
           .mapError { error in error }
           .eraseToAnyPublisher()
    }
    
    func dataFrom(url: URL)  async throws -> (Data, URLResponse) {
       try await URLSession.shared.data(from: url)
    }
}

struct NetworkManager: NetworkManagerProtocol {
    private var sessionManager: URLSessionManagerProtocol
    
    init(sessionManager: URLSessionManagerProtocol = URLSessionManager()) {
        self.sessionManager = sessionManager
    }
    
    func downloadJSON(from urlString: String) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        return sessionManager.dataTaskPublisher(url: url)
            .mapError({ error in NetworkError.unknown(error)})
            .eraseToAnyPublisher()
    }
    
    func fetchAndDecode<T: Decodable>(from urlString: String, as type: T.Type) -> AnyPublisher<T, NetworkError> {
        return downloadJSON(from: urlString)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkError.unknown(decodingError)
                }
                return error as? NetworkError ?? NetworkError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
}
