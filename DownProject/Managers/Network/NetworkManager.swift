//
//  NetworkManager.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation
import Combine

struct NetworkManager: NetworkManagerProtocol {
    func downloadJSON(from urlString: String) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .mapError { error in NetworkError.unknown(error) }
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
