//
//  FilterCollectionViewCell.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class FilterCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "FilterCollectionViewCell"

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var filterImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.filterImage.clipsToBounds = true
        self.filterImage.layer.cornerRadius = 30
        self.filterImage.contentMode = .scaleToFill
        self.filterImage.layer.borderWidth = 1
        self.filterImage.layer.borderColor = UIColor.white.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filterImage.image = nil
        title.text = nil
    }
    
    func setupWith(title: String, imageName: String) {
        self.title.text = title
        self.filterImage.image = UIImage(named: imageName)
    }
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected, !oldValue {
                title.textColor = .white
                filterImage.layer.borderWidth = 2
                filterImage.layer.borderColor = UIColor.purple.cgColor
            } else if !isSelected, oldValue {
                title.textColor = .lightGray
                filterImage.layer.borderWidth = 1
                filterImage.layer.borderColor = UIColor.white.cgColor
            }
        }
    }

}
