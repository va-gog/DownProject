//
//  FiltersCollectionViewManager.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class FiltersCollectionViewManager: NSObject, UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    private var viewModel: MainScreenViewModelInterface
    private var filtersViewContainer: UIView
    private var theme = FiltersCollectionViewTheme()
    
    var filtersCollectionView: UICollectionView?
    var didSelectFilter: (() -> Void)?
    
    init(viewModel: MainScreenViewModelInterface, filtersViewContainer: UIView) {
        self.viewModel = viewModel
        self.filtersViewContainer = filtersViewContainer
        super.init()
        self.setupFilterCollectionView()
    }
    
    func selectFilterIfNeeded() {
        guard filtersCollectionView?.indexPathsForSelectedItems?.isEmpty ?? false else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let collectionView = self.filtersCollectionView {
                let initialIndexPath = IndexPath(item: 0, section: 0)
                collectionView.selectItem(at: initialIndexPath, animated: true, scrollPosition: .centeredVertically)
                collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: initialIndexPath)
            }
        }
    }
    
    private func setupFilterCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = theme.minimumLineSpacing
        layout.sectionInset = theme.sectionInset
        
        let collectionView = UICollectionView(frame: CGRect(origin: .zero,
                                                            size: filtersViewContainer.bounds.size),
                                              collectionViewLayout: layout)
        let nib = UINib(nibName: FilterCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: FilterCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        filtersViewContainer.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: filtersViewContainer.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: filtersViewContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: filtersViewContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: filtersViewContainer.trailingAnchor)
        ])
        
        self.filtersCollectionView = collectionView
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
    
    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return theme.cellSize
    }
}
