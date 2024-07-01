//
//  FiltersCollectionViewManager.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class FiltersCollectionViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var viewModel: MainScreenViewModelInterface
    private var filtersViewContainer: UIView
    private var theme = FiltersCollectionViewTheme()
    
    var filtersCollectionView: UICollectionView
    var didSelectFilter: (() -> Void)?
    
    init(viewModel: MainScreenViewModelInterface, filtersViewContainer: UIView) {
        self.viewModel = viewModel
        self.filtersViewContainer = filtersViewContainer
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = theme.minimumLineSpacing
        layout.sectionInset = theme.sectionInset
        
        filtersCollectionView = UICollectionView(frame: CGRect(origin: .zero,
                                                            size: filtersViewContainer.bounds.size),
                                              collectionViewLayout: layout)
        super.init()
        self.setupFilterCollectionView()
    }
    
    private func setupFilterCollectionView() {
        let nib = UINib(nibName: FilterCollectionViewCell.reuseIdentifier, bundle: nil)
        filtersCollectionView.register(nib, forCellWithReuseIdentifier: FilterCollectionViewCell.reuseIdentifier)
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.backgroundColor = .clear
        
        filtersViewContainer.addSubview(filtersCollectionView)
        
        filtersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filtersCollectionView.topAnchor.constraint(equalTo: filtersViewContainer.topAnchor),
            filtersCollectionView.bottomAnchor.constraint(equalTo: filtersViewContainer.bottomAnchor),
            filtersCollectionView.leadingAnchor.constraint(equalTo: filtersViewContainer.leadingAnchor),
            filtersCollectionView.trailingAnchor.constraint(equalTo: filtersViewContainer.trailingAnchor)
        ])
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? FilterCollectionViewCell else {
            fatalError("Cell must be FilterCollectionViewCell type")
        }
        let filter = viewModel.filters[indexPath.item]
        cell.setupWith(title: filter.title, imageName: filter.imageName)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel.shouldSelectFilter(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = viewModel.filters[indexPath.item].profilesURL
        viewModel.filterSelected(at: indexPath.item)
        didSelectFilter?()
        Task {
           await viewModel.downloadProfiles(urlString: urlString)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        selectFilterIfNeeded(initialIndexPath: IndexPath(item: 0, section: 0))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return theme.cellSize
    }
    
    // MARK:  Helpers
    
    private func selectFilterIfNeeded(initialIndexPath: IndexPath) {
        DispatchQueue.main.async {
            guard self.filtersCollectionView.indexPathsForSelectedItems?.isEmpty ?? false,
                self.filtersCollectionView.cellForItem(at: initialIndexPath) != nil else { return }
            self.filtersCollectionView.selectItem(at: initialIndexPath, animated: true, scrollPosition: .centeredVertically)
            self.filtersCollectionView.delegate?.collectionView?(self.filtersCollectionView, didSelectItemAt: initialIndexPath)
        }
    }
}
