//
//  MainScreenViewModel.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit
import Combine

final class MainScreenViewModel: MainScreenViewModelInterface {
    @Published var downloadState: DownloadState = .none
    @Published var profiles: [ProfileModel]
    @Published var filters: [FilterModel]
    var selectedFilterIndex: Int = 0
    
    private var cacheManager: ImageCacheManager
    private let networkManager: NetworkManagerProtocol
    
    private var cancellable: AnyCancellable?
    
    init(cacheManager: ImageCacheManager = ImageCacheManager(cache: NSCache<NSString, NSData>()),
         downloadState: DownloadState = .none,
         profiles: [ProfileModel] = [],
         filters: [FilterModel] = [],
         networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.cacheManager = cacheManager
        self.downloadState = downloadState
        self.profiles = profiles
        self.networkManager = networkManager
        self.filters = filters
        cacheManager.configureCache(countLimit: 50,
                                    totalCostLimit: 50 * 1024 * 1024)
    }
    
    func downloadProfiles(urlString: String) async {
        downloadState = .loading
        cancellable = networkManager.fetchAndDecode(from: urlString, as: [ProfileModel].self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.downloadState = .finished
                case .failure(let error):
                    self?.downloadState = .failed(error)
                }
            }, receiveValue: { [weak self] dataModel in
                self?.profiles = []
            })
    }
    
    func loadFilters() async throws {
            guard let url = Bundle.main.url(forResource: "Filters", withExtension: "json") else {
                throw NetworkError.badURL
            }
            
            do {
                let data = try Data(contentsOf: url)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = jsonObject as? [String: Any],
                   let carDict = jsonDict["filters"] as? [[String: Any]] {
                    let decoder = JSONDecoder()
                    let filterData = try JSONSerialization.data(withJSONObject: carDict, options: [])
                    filters = try decoder.decode([FilterModel].self, from: filterData)
                }
            } catch {
                throw NetworkError.decodingFailed
            }
        }
    
    func loadProfileImage(urlString: String) async throws -> Data {
       try await cacheManager.downloadAndCacheData(urlString: urlString)
    }
    
    func shouldSelectFilter(at index: Int) -> Bool {
        index != selectedFilterIndex
    }
    
    func filterSelected(at index: Int) {
        self.selectedFilterIndex = index
    }
}
