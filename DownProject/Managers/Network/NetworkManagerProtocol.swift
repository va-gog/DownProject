//
//  NetworkManagerProtocol.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func downloadJSON(from urlString: String) -> AnyPublisher<Data, NetworkError>
    func fetchAndDecode<T: Decodable>(from urlString: String, as type: T.Type) -> AnyPublisher<T, NetworkError>
}
