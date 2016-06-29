//
//  FirstChildViewController.swift
//  ControllerCollection
//
//  Created by Chris Budro on 6/29/16.
//  Copyright © 2016 Chris Budro. All rights reserved.
//

import UIKit

class FirstChildViewController: CollectionChildViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let CellReuseIdentifier = "Cell"
    }
    
    var imageCollection = [UIImage]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.CellReuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    //MARK: Collection View data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellReuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        let image = imageCollection[indexPath.row]
        cell.imageView.image = image
        
        return cell
    }
    
    
    //MARK: Flow layout delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return view.bounds.size
    }
    
    override func prepareForReuse() {
        imageCollection.removeAll()
        collectionView.setContentOffset(CGPointZero, animated: false)
    }
}
