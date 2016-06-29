//
//  ControllerCollectionViewCell.swift
//  ControllerCollectionView
//
//  Created by Chris Budro on 3/9/16.
//  Copyright © 2016 Vectorform. All rights reserved.
//

import UIKit

class ControllerCollectionContainerCell: UICollectionViewCell {
    var controllerView: UIView? {
        didSet {
            if let controllerView = controllerView {
                contentView.addSubview(controllerView)
                
                controllerView.translatesAutoresizingMaskIntoConstraints = false
                
                let topConstraint = NSLayoutConstraint(item: controllerView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0)
                let leftConstraint = NSLayoutConstraint(item: controllerView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0)
                let rightConstraint = NSLayoutConstraint(item: controllerView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0)
                let bottomConstraint = NSLayoutConstraint(item: controllerView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0)
                
                [topConstraint, leftConstraint, rightConstraint, bottomConstraint].forEach() { $0.active = true }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
//        controllerView?.removeFromSuperview()
        controllerView = nil
    }
}
