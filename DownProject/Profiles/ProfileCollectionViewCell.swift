//
//  ProfileCollectionViewCell.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileCollectionViewCell"

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.cornerRadius = 30
        clipsToBounds = true
        
        profileImage.layer.cornerRadius = 30
        profileImage.contentMode = .scaleAspectFill
        
        stackView.layer.cornerRadius = 20
        stackView.isHidden = true
        stackView.alpha = 0.5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 20)
        
        icon.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.isHidden = true
        stackView.alpha = 0.5
        stackView.isHidden = true
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
    
    func activateAction(imageName: String, action: String) {
        infoContainer.isHidden = true
        stackView.isHidden = false
        actionLabel.text = action
        icon.image = UIImage(systemName: imageName)
    }
    
    func changeOpacity(_ alpha: CGFloat) {
        stackView.alpha = alpha
    }
}
