//
//  DownloadState.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation

enum DownloadState: Equatable {
    case loading
    case finished
    case failed(NetworkError)
    case none
}
