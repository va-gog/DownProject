//
//  NetworkError.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case requestFailed
    case decodingFailed
    case unknown(Error)
}

