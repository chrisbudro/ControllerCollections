//
//  ControllerReuseManager.swift
//  ControllerCollectionView
//
//  Created by Chris Budro on 3/17/16.
//  Copyright © 2016 Vectorform. All rights reserved.
//

import UIKit

class ControllerReuseManager {
    
    var controllerClassDict = [String: CollectionChildViewController.Type]()
    var controllerNibDict = [String: String]()
    var controllerReuseQueue = [String: Set<CollectionChildViewController>]()
    
    func registerClass(cellClass: CollectionChildViewController.Type, forReuseIdentifier reuseIdentifier: String) {
        controllerClassDict[reuseIdentifier] = cellClass
    }
    
    func registerClass(cellClass: CollectionChildViewController.Type, withNibName nibName: String, forReuseIdentifier reuseIdentifier: String) {
        controllerClassDict[reuseIdentifier] = cellClass
        controllerNibDict[reuseIdentifier] = nibName
    }
    
    func enqueueReusableController(reusableController: CollectionChildViewController, withIdentifier reuseID: String?) {
        guard let reuseID = reuseID else {
            //TODO: Throw exception?
            return
        }
        reusableController.view.removeFromSuperview()
        reusableController.prepareForReuse()
        
        if let _ = controllerReuseQueue[reuseID] {
            controllerReuseQueue[reuseID]!.insert(reusableController)
        } else {
            controllerReuseQueue[reuseID] = []
            controllerReuseQueue[reuseID]!.insert(reusableController)
        }
    }
    
    func dequeueViewControllerWithReuseIdentifierIfAvailable(reuseID: String) -> CollectionChildViewController? {
        if let reusableControllers = controllerReuseQueue[reuseID] where reusableControllers.count > 1 {
            if let dequeuedController = controllerReuseQueue[reuseID]?.popFirst() {
                return dequeuedController
            }
        }
        return nil
    }
    
    func newViewControllerWithReuseIdentifier(reuseID: String) -> CollectionChildViewController {
        let newController: CollectionChildViewController
        
        guard let controllerClass = controllerClassDict[reuseID] else {
            fatalError("Class is not registered for identifier \(reuseID)")
        }
        
        //Check if controller was registered with a Nib
        if let controllerNibName = controllerNibDict[reuseID] {
            newController = controllerClass.init(nibName: controllerNibName, bundle: nil)
        } else {
            newController = controllerClass.init()
        }
        
        if #available(iOS 9.0, *) {
            newController.loadViewIfNeeded()
        } else {
            let _ = newController.view
        }
        
        newController.reuseIdentifier = reuseID

        return newController
    }
    
    func clearReuseQueue() {
        controllerReuseQueue = [String: Set<CollectionChildViewController>]()
    }
}
