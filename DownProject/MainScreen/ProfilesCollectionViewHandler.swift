//
//  ProfilesCollectionViewHandler.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class ProfilesCollectionViewHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    private var viewModel: MainScreenViewModelInterface
    private var profilesViewContainer: UIView
    
    var profilesCollectionView: UICollectionView?
    
    init(viewModel: MainScreenViewModelInterface, profilesViewContainer: UIView) {
        self.viewModel = viewModel
        self.profilesViewContainer = profilesViewContainer
        super.init()
        setupProfilesCollectionView()
    }
    
    private func setupProfilesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 40
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: CGRect(origin: .zero,
                                                            size: profilesViewContainer.bounds.size),
                                              collectionViewLayout: layout)
        let nib = UINib(nibName: ProfileCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        
        profilesViewContainer.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor)
        ])
        profilesCollectionView = collectionView

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        collectionView.addGestureRecognizer(panGesture)
    }
    
    
    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let profilesCollectionView else { return }
        let location = gesture.location(in: profilesCollectionView)
        
        guard let indexPath = profilesCollectionView.indexPathForItem(at: location),
              let cell = profilesCollectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell else { return }
        
        let translation = gesture.translation(in: profilesCollectionView)
        var diff: CGFloat = 0
        switch gesture.state {
        case .began:
            if translation.y < 0 {
                cell.activateAction(imageName: "heart.fill", action: "DATE")
            } else if translation.y > 0 {
                cell.activateAction(imageName: "flame.fill", action: "DOWN")
            }
        case .changed:
            cell.moveImage(tranform: CGAffineTransform(translationX: 0, y: translation.y))
            diff +=  translation.y
            if abs(diff) > 100 {
                UIView.animate(withDuration: 0.5) {
                    cell.changeOpacity(0.9)
                    cell.moveImage(tranform: .identity)
                    gesture.state = .ended
                } completion: { finished in
                    if finished {
                        guard let visibleIndexPath = profilesCollectionView.indexPathsForVisibleItems.first else { return }
                        let nextIndexPath = IndexPath(row: visibleIndexPath.item + 1, section: visibleIndexPath.section)
                        guard let attributes = profilesCollectionView.layoutAttributesForItem(at: nextIndexPath) else { return }
                        profilesCollectionView.setContentOffset(CGPoint(x: attributes.frame.minX - 20,
                                                                        y: 0),
                                                                animated: true)
                    }
                }

            }
        case .ended:
            UIView.animate(withDuration: 0.3, animations: {
                cell.moveImage(tranform: .identity)
            })
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
            guard let visibleIndexPath = getSmallestVisibleIndexPath(),
                  let attributes = profilesCollectionView?.layoutAttributesForItem(at: visibleIndexPath) else { return }
            if abs(profilesCollectionView?.contentOffset.x ?? 0) < attributes.frame.minX + attributes.size.width / 2 + 20 {
                profilesCollectionView?.setContentOffset(CGPoint(x: attributes.frame.minX - 20,
                                                                 y: profilesCollectionView?.contentOffset.y ?? 0),
                                                         animated: true)
            } else {
                let nextIndexPath = IndexPath(item: visibleIndexPath.item + 1, section: visibleIndexPath.section)
                let nextAttributes = profilesCollectionView?.layoutAttributesForItem(at: nextIndexPath) ?? attributes
                profilesCollectionView?.setContentOffset(CGPoint(x: nextAttributes.frame.minX - 20,
                                                                 y: profilesCollectionView?.contentOffset.y ?? 0),
                                                         animated: true)
            }
            
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: profilesViewContainer.bounds.size.width - 2 * 20, height: profilesViewContainer.bounds.size.height)
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print(gestureRecognizer)
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
              let velocity = panGestureRecognizer.velocity(in: profilesViewContainer)

              if gestureRecognizer == self.profilesCollectionView?.panGestureRecognizer {
                  return abs(velocity.x) > abs(velocity.y)
              } else {
                  return abs(velocity.y) > abs(velocity.x)
              }
          } else {
              return true
          }
    }
    
    // MARK: Helpers
    
    private func getSmallestVisibleIndexPath() -> IndexPath? {
           let visibleIndexPaths = profilesCollectionView?.indexPathsForVisibleItems
           return visibleIndexPaths?.sorted().first
       }
    
    private func getLargestVisibleIndexPath() -> IndexPath? {
           let visibleIndexPaths = profilesCollectionView?.indexPathsForVisibleItems
           return visibleIndexPaths?.sorted().last
       }
}
