//
//  UIView+Extension.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import UIKit

extension UIView {
    
    func addSubviewWithConstraintToSafeArea(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: subview.bottomAnchor, multiplier: 1.0),
            subview.leadingAnchor.constraint(equalToSystemSpacingAfter: guide.leadingAnchor, multiplier: 1.0),
            guide.trailingAnchor.constraint(equalToSystemSpacingAfter: subview.trailingAnchor, multiplier: 1.0)
         ])
    }
    
    func addSubviewWithConstraintToSuperView(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subview, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subview, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
         ])
    }
}
