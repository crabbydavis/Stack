//
//  Checklist.swift
//  Stack
//
//  Created by Davis Crabb on 5/28/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class Checklist: NSObject, NSCoding {
    
    var name: String = ""
    var nearby: Bool = false
    var image: UIImage?

    init(checklistName: String){
        name = checklistName
    }
    
    init(checklistName: String, checklistNearby: Bool, checklistImage: UIImage?){
        name = checklistName
        nearby = checklistNearby
        image = checklistImage
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey:"checklistName")
        aCoder.encode(nearby, forKey: "checklistNearby")
        aCoder.encode(image, forKey: "checklistImage")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "checklistName") as! String
        let nearby = aDecoder.decodeBool(forKey: "checklistNearby")
        //let image = aDecoder.decodeObject(forKey: "checklistImage") as! UIImage
        var image: UIImage?
        if let dataImage = aDecoder.decodeObject(forKey: "checklistImage") as? UIImage {
            image = dataImage
        }
        self.init(checklistName:name, checklistNearby:nearby, checklistImage:image)
    }
}
