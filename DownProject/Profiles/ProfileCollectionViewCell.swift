//
//  ProfileCollectionViewCell.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileCollectionViewCell"

    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var actionLabel: UILabel!
    
    private let theme = ProfileCollectionViewCellTheme()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.cornerRadius = theme.containerCornerradius
        clipsToBounds = true
        
        profileImage.layer.cornerRadius = theme.profileImageCornerRadius
        profileImage.contentMode = .scaleAspectFill
        
        stackView.layer.cornerRadius = theme.stackViewCornerradius
        stackView.alpha = theme.stackViewAlpha
        stackView.isHidden = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = theme.stackViewLayoutMargins
        
        icon.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.isHidden = true
        stackView.alpha = theme.stackViewAlpha
        icon.image = nil
        actionLabel.text = nil
        nameLabel.text = nil
        ageLabel.text = nil
        profileImage.image = nil
        infoContainer.isHidden = false
    }
    
    func setProfilePicture(_ image: UIImage) {
        profileImage.image = image
    }
    
    func setAge(_ age: String) {
        ageLabel.text = age
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func moveImage(tranform: CGAffineTransform) {
        profileImage.transform = tranform
    }
    
    func deactivateAction() {
        infoContainer.isHidden = false
        stackView.isHidden = true
        actionLabel.text = nil
        icon.image = nil
    }
    
    func activateAction(actionModel: SwipeActionModel) {
        infoContainer.isHidden = true
        stackView.isHidden = false
        actionLabel.text = actionModel.type.rawValue
        icon.image = UIImage(systemName: actionModel.iconName)
    }
    
    func changeOpacity(_ alpha: CGFloat) {
        stackView.alpha = alpha
    }
}


