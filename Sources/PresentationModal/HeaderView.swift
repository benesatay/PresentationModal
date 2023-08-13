//
//  HeaderView.swift
//  
//
//  Created by Bahadır Enes Atay on 12.08.2023.
//

import UIKit
import SnapKit

public protocol HeaderViewDelegate: AnyObject {
    func didBackButtonTapped()
}

open class HeaderView: UIView {
    
    // MARK: - Views
    public lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didBackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    public lazy var seperatorView: UIView = {
        let seperatorView = UIView()
        seperatorView.backgroundColor = .systemGray4
        seperatorView.layer.cornerRadius = 2
        return seperatorView
    }()
    
    // MARK: - Public Properties
    weak var delegate: HeaderViewDelegate?
    
//    weak var dataSource: HeaderViewDataSource?
    
    // MARK: - Init
    public init() {
        super.init(frame: .zero)
        setViewAppearance()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setViewAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    // MARK: - Public Methods
    public func setCloseButton() {
        setCloseButtonConstraints()
    }
    
    public func setSeperator() {
        setSeperatorContstraints()
    }
    
    private func setCloseButtonConstraints() {
        seperatorView.removeFromSuperview()
        seperatorView.snp.removeConstraints()
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(safeAreaInsets.top + 16)
            make.leading.equalToSuperview().inset(16)
        }
    }
    
    private func setSeperatorContstraints() {
        closeButton.removeFromSuperview()
        closeButton.snp.removeConstraints()
        addSubview(seperatorView)
        seperatorView.snp.makeConstraints({ make in
            make.height.equalTo(4)
            make.width.equalTo(44)
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(24)
        })
    }
    
    // MARK: - Actions
    @objc private func didBackButtonTapped() {
        delegate?.didBackButtonTapped()
    }
}
