//
//  EmptyView.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

final class EmptyView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    init(title: String, subtitle: String, frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        nibView.frame = bounds
        nibView.backgroundColor = .clear
        nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(nibView)
    }
}
