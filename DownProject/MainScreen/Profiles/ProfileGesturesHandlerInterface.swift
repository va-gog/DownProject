//
//  ProfileGesturesHandlerInterface.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

protocol ProfileGesturesHandlerInterface {
    mutating func handleSwipeAction(velocity: CGPoint) -> SwipeActionModel
    mutating func shouldEndSwipeAction(translation: CGPoint) -> Bool
    func swipeActionDidEnd(profilesCollectionView: UICollectionView)
    func collectionViewDidEndScrolling(profilesCollectionView: UIScrollView)
}
