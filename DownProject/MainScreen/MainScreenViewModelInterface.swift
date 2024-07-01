//
//  MainScreenViewModelInterface.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation

protocol MainScreenViewModelInterface {
    var selectedFilterIndex: Int { get }
    var downloadState: DownloadState  { get }
    var profiles: [ProfileModel] { get }
    var filters: [FilterModel] { get }

    func downloadProfiles(urlString: String) async
    func loadFilters(url: URL?) async throws
    func loadProfileImage(urlString: String) async throws -> Data
    func filterSelected(at index: Int)
    func shouldSelectFilter(at index: Int) -> Bool
}
