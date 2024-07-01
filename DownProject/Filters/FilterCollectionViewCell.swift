//
//  FilterCollectionViewCell.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class FilterCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "FilterCollectionViewCell"

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var filterImage: UIImageView!
    
    private let theme = FilterCollectionViewCellTheme()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.filterImage.clipsToBounds = true
        self.filterImage.layer.cornerRadius = theme.cornerRadius
        self.filterImage.contentMode = .scaleToFill
        self.filterImage.layer.borderWidth = theme.deselectedBorderWidth
        self.filterImage.layer.borderColor = theme.deselectedBorderColor.cgColor
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
                filterImage.layer.borderWidth = theme.selectedBorderWidth
                filterImage.layer.borderColor = theme.selectedBorderColor.cgColor
            } else if !isSelected, oldValue {
                title.textColor = .lightGray
                filterImage.layer.borderWidth = theme.deselectedBorderWidth
                filterImage.layer.borderColor = theme.deselectedBorderColor.cgColor
            }
        }
    }

}
