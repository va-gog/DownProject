//
//  ErrorView.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit

class ErrorHUDView: UIView {
    private let label = UILabel()
    private let button = UIButton(type: .system)
    private let theme = ErrorHUDViewTheme()
    
    var retryAction: (() -> Void)?
    
    init(message: String, buttonTitle: String, retryAction: @escaping () -> Void) {
        self.retryAction = retryAction
        super.init(frame: .zero)
        setupView(message: message, buttonTitle: buttonTitle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(message: "", buttonTitle: "")
    }
    
    private func setupView(message: String, buttonTitle: String) {
        label.textColor = theme.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = message
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = theme.buttonBackgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = theme.buttonCornerRadius
        button.layer.borderWidth = theme.buttonBorderWidth
        button.layer.borderColor = theme.buttonBorderColor
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -theme.labelCenterYAnchor),
            label.heightAnchor.constraint(equalToConstant: theme.labelHeightAnchor),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: theme.labelWidthAnchor),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: theme.buttonTopAnchor),
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: theme.buttonHeightAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: theme.buttonWidthAnchor)
        ])
    }
    
    @objc private func retryButtonTapped() {
        retryAction?()
    }
}
