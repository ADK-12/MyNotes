//
//  CollectionSectionHeaderView.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 15/08/25.
//

import UIKit

class CollectionSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "MySectionHeader"

        let titleLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
