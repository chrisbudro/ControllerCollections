//
//  ImageCollections.swift
//  ControllerCollection
//
//  Created by Chris Budro on 6/29/16.
//  Copyright © 2016 Chris Budro. All rights reserved.
//

import UIKit

class ImageCollections {
    
    class func getImageCollections() -> [ImageCollection] {
        var collections = [ImageCollection]()
        
        collections.append([UIImage(named: "photo1")!, UIImage(named: "photo2")!])
        collections.append([UIImage(named: "photo3")!, UIImage(named: "photo4")!])
        collections.append([UIImage(named: "photo5")!, UIImage(named: "photo1")!])
        collections.append([UIImage(named: "photo2")!, UIImage(named: "photo3")!])
        collections.append([UIImage(named: "photo6")!, UIImage(named: "photo7")!])
        collections.append([UIImage(named: "photo8")!, UIImage(named: "photo9")!])
        collections.append([UIImage(named: "photo10")!, UIImage(named: "photo11")!])
        collections.append([UIImage(named: "photo12")!, UIImage(named: "photo13")!])
        collections.append([UIImage(named: "photo14")!, UIImage(named: "photo15")!])
        collections.append([UIImage(named: "photo16")!, UIImage(named: "photo17")!])
        collections.append([UIImage(named: "photo18")!, UIImage(named: "photo19")!])
        collections.append([UIImage(named: "photo20")!, UIImage(named: "photo21")!])
        collections.append([UIImage(named: "photo22")!, UIImage(named: "photo3")!])
        
        return collections
    }
}