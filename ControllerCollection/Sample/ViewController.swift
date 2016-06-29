//
//  ViewController.swift
//  ControllerCollection
//
//  Created by Chris Budro on 6/29/16.
//  Copyright © 2016 Chris Budro. All rights reserved.
//

import UIKit

typealias ImageCollection = [UIImage]

class ViewController: UIViewController, ControllerCollectionViewDataSource, ControllerCollectionViewDelegate {

    private let imageCollections = ImageCollections.getImageCollections()

    private struct Constants {
        static let ControllerReuseIdentifier = "Controller"
    }

    private lazy var controllerCollection: ControllerCollectionViewController = {
        let collectionController = ControllerCollectionViewController()
        collectionController.dataSource = self
        collectionController.delegate = self
        collectionController.registerClass(FirstChildViewController.self, withNibName: "FirstChildViewController", forReuseIdentifier: Constants.ControllerReuseIdentifier)
        return collectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllerCollection.addCollectionToParentController(self)
    }
    
    //MARK: Controller Data Source
    
    func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, numberOfItemsInSection section: Int) -> Int {
        return imageCollections.count
    }
    
    func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, controllerForItemAtIndexPath indexPath: NSIndexPath) -> CollectionChildViewController {
        
        let controller = controllerCollectionView.dequeueViewControllerWithReuseIdentifier(Constants.ControllerReuseIdentifier) as! FirstChildViewController
        
        let imageCollection = imageCollections[indexPath.row]
        
        controller.imageCollection = imageCollection
        
        return controller
    }

    //MARK: Flow Layout Delegate 
    func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = view.bounds.width
        let height = view.bounds.height * 0.33
        
        return CGSize(width: width, height: height)
    }
}




