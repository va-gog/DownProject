//
//  ProfilesCollectionViewManager.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class ProfilesCollectionViewManager: NSObject, UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    var profilesCollectionView: UICollectionView
    
    private var viewModel: MainScreenViewModelInterface
    private var gestureHandler: ProfileGesturesHandlerInterface
    private var profilesViewContainer: UIView
    private let theme = ProfilesCollectionViewTheme()
    
    init(viewModel: MainScreenViewModelInterface, profilesViewContainer: UIView, gestureHandler: ProfileGesturesHandlerInterface = ProfileGesturesHandler()) {
        self.viewModel = viewModel
        self.profilesViewContainer = profilesViewContainer
        self.gestureHandler = gestureHandler
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = theme.minimumLineSpacing
        layout.sectionInset = theme.sectionInset
        profilesCollectionView = UICollectionView(frame: CGRect(origin: .zero,
                                                                size: profilesViewContainer.bounds.size),
                                                  collectionViewLayout: layout)
        super.init()
        setupProfilesCollectionView()
    }
    
    private func setupProfilesCollectionView() {
        let nib = UINib(nibName: ProfileCollectionViewCell.reuseIdentifier, bundle: nil)
        profilesCollectionView.register(nib, forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        profilesCollectionView.dataSource = self
        profilesCollectionView.delegate = self
        profilesCollectionView.prefetchDataSource = self
        profilesCollectionView.backgroundColor = .clear
        profilesCollectionView.isHidden = true
        
        profilesViewContainer.addSubview(profilesCollectionView)
        profilesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profilesCollectionView.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
            profilesCollectionView.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
            profilesCollectionView.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor),
            profilesCollectionView.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        profilesCollectionView.addGestureRecognizer(panGesture)
    }
    
    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: profilesCollectionView)
        
        guard let indexPath = profilesCollectionView.indexPathForItem(at: location),
              let cell = profilesCollectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell else { return }
        
        let translation = gesture.translation(in: profilesCollectionView)
        switch gesture.state {
        case .began:
            let velocity = gesture.velocity(in: profilesViewContainer)
            let model = gestureHandler.handleSwipeAction(velocity: velocity)
            cell.activateAction(actionModel: model)
        case .changed:
            cell.moveImage(tranform: CGAffineTransform(translationX: 0, 
                                                       y: translation.y))
            guard gestureHandler.shouldEndSwipeAction(translation: translation) else { return }
            UIView.animate(withDuration: theme.animationDuration) {
                cell.changeOpacity(self.theme.finalOpacity)
                gesture.state = .ended
            }
            
        case .ended:
            UIView.animate(withDuration: theme.animationDuration) {
                cell.moveImage(tranform: .identity)
            } completion: { _ in
                cell.deactivateAction()
                self.gestureHandler.swipeActionDidEnd(profilesCollectionView: self.profilesCollectionView)
            }
        default:
            break
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.profiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? ProfileCollectionViewCell else {
            fatalError("Cell must be ProfileCollectionViewCell type")
        }
        let profile = viewModel.profiles[indexPath.item]
        cell.setAge(String(profile.age))
        cell.setName(profile.name)
        Task {
            do {
                let data = try await viewModel.loadProfileImage(urlString: profile.profilePicUrl)
                DispatchQueue.main.async {
                    guard let image = UIImage(data: data) else { return }
                    cell.setProfilePicture(image)
                }
            } catch {
                // TODO: Handle error when image is absent
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            gestureHandler.collectionViewDidEndScrolling(profilesCollectionView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)  {
        gestureHandler.collectionViewDidEndScrolling(profilesCollectionView: scrollView)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: profilesViewContainer.bounds.size.width - 2 * ProfilesCollectionViewTheme.verticalInset,
                      height: profilesViewContainer.bounds.size.height)
    }
    
    // MARK: UICollectionViewDataSourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let profile = viewModel.profiles[indexPath.item]
            Task {
                try await viewModel.loadProfileImage(urlString: profile.profilePicUrl)
            }
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: profilesViewContainer)
            
            if gestureRecognizer == profilesCollectionView.panGestureRecognizer {
                return abs(velocity.x) > abs(velocity.y)
            } else {
                return abs(velocity.y) > abs(velocity.x)
            }
        } else {
            return true
        }
    }
}
