//
//  EmptyLabelView.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/23.
//

import SnapKit
import UIKit

final class EmptyLabelView: UIView {
    
    private let text: String
    
    private lazy var emptyLabel: UILabel = {
        let textLabel = UILabel()
        //textLabel.isHidden = true
        textLabel.text = text
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 20.0)
        return textLabel
    }()
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
