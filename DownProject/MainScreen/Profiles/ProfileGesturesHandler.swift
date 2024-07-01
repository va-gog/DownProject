//
//  ProfileGesturesHandler.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

struct ProfileGesturesHandler: ProfileGesturesHandlerInterface {
    private var isFinished = false

    mutating func handleSwipeAction(velocity: CGPoint) -> SwipeActionModel {
        isFinished = false
        if velocity.y < 0 {
            return SwipeActionModel(type: .date, iconName: SwipeAction.date.icon)
        } else if velocity.y > 0 {
            return SwipeActionModel(type: .down, iconName: SwipeAction.down.icon)
        }
        return SwipeActionModel(type: .none, iconName: SwipeAction.none.icon)
    }
    
    mutating func shouldEndSwipeAction(translation: CGPoint) -> Bool {
        if abs(translation.y) > ProfilesCollectionViewTheme.swipeEndArea {
            isFinished = true
            return true
        }
        return false
    }
    
    func swipeActionDidEnd(profilesCollectionView: UICollectionView) {
        guard isFinished else { return }
        guard let visibleIndexPath = profilesCollectionView.indexPathsForVisibleItems.first else { return }
        let nextIndexPath = IndexPath(row: visibleIndexPath.item + 1, section: visibleIndexPath.section)
        guard let attributes = profilesCollectionView.layoutAttributesForItem(at: nextIndexPath) else { return }
        profilesCollectionView.setContentOffset(CGPoint(x: attributes.frame.minX - ProfilesCollectionViewTheme.verticalInset,
                                                        y: 0),
                                                animated: true)
    }
    
    func collectionViewDidEndScrolling(profilesCollectionView: UIScrollView) {
        guard let profilesCollectionView = profilesCollectionView as? UICollectionView else { return }
        guard let visibleIndexPath = getSmallestVisibleIndexPath(profilesCollectionView: profilesCollectionView),
              let attributes = profilesCollectionView.layoutAttributesForItem(at: visibleIndexPath) else { return }
        if abs(profilesCollectionView.contentOffset.x) < attributes.frame.minX + attributes.size.width / 2 + ProfilesCollectionViewTheme.verticalInset {
            profilesCollectionView.setContentOffset(CGPoint(x: attributes.frame.minX - ProfilesCollectionViewTheme.verticalInset,
                                                             y: profilesCollectionView.contentOffset.y),
                                                     animated: true)
        } else {
            let nextIndexPath = IndexPath(item: visibleIndexPath.item + 1, section: visibleIndexPath.section)
            let nextAttributes = profilesCollectionView.layoutAttributesForItem(at: nextIndexPath) ?? attributes
            profilesCollectionView.setContentOffset(CGPoint(x: nextAttributes.frame.minX - ProfilesCollectionViewTheme.verticalInset,
                                                             y: profilesCollectionView.contentOffset.y),
                                                     animated: true)
        }
    }
    
    private func getSmallestVisibleIndexPath(profilesCollectionView: UICollectionView) -> IndexPath? {
           let visibleIndexPaths = profilesCollectionView.indexPathsForVisibleItems
           return visibleIndexPaths.sorted().first
       }
    
    private func getLargestVisibleIndexPath(profilesCollectionView: UICollectionView) -> IndexPath? {
           let visibleIndexPaths = profilesCollectionView.indexPathsForVisibleItems
           return visibleIndexPaths.sorted().last
       }
}
