//
//  CollectionViewControllerCell.swift
//  ControllerCollectionView
//
//  Created by Chris Budro on 3/10/16.
//  Copyright © 2016 Vectorform. All rights reserved.
//

import UIKit

public class CollectionChildViewController: UIViewController {

    var reuseIdentifier: String?
    var indexPath: NSIndexPath?

    
    /** 
        Making initWithNibName a required initializer for all subclasses so it can be used on a class Metatype
        for example:
        classType = CollectionChildViewController.Type
        classType.init(nibName: NIB_NAME, bundle: BUNDLE)
    */
    required override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func prepareForReuse() {
        indexPath = nil
    }
}
