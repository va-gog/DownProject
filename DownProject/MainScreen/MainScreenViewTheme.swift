//
//  MainScreenViewTheme.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

struct MainScreenViewTheme {
    static let emptyViewBackgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
    
    let bottomTabBarBackgorunColor = UIColor.black
    let bottomTabBarTintColor = UIColor.white
    let bottomTabBarUnselectedItemTintColor = UIColor.lightGray
    
    let seperatorBackgroundColor = UIColor.darkGray
    let seperatorHeight: CGFloat = 1
    
    let myProfileImg = "pic_profile"
    
    let myProfileButtonBorderColor = UIColor.white.cgColor
    let myProfileButtonCornerRadius: CGFloat = 15
    let myProfileButtonBorderWidth: CGFloat = 2
    let myProfileButtonTopAnchor: CGFloat = 5
    let myProfileButtonBottomAnchor: CGFloat =  -5
    let myProfileButtonWidthAnchor: CGFloat =  30
    let myProfileButtonLeadingAnchor: CGFloat = 10
    let myProfileButtonImageViewSize: CGFloat = 30
    
    let emptyViewVerticalInset: CGFloat = 20
    let emptyViewCornerRadius: CGFloat = 30
    let emptyViewBorderWidth: CGFloat = 1
    let emptyViewBorderColor = UIColor.white.cgColor
    
    let indicatorTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    let indicatorColor = UIColor.white
}
