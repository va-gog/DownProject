//
//  ImageCacheManagerInterface.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation

protocol ImageCacheManagerInterface {
    func downloadAndCacheData(urlString: String) async throws -> Data
    func configureCache(countLimit: Int, totalCostLimit: Int)
}
