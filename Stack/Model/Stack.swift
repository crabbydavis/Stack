//
//  Stack.swift
//  Stack
//
//  Created by Davis Crabb on 5/28/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class Stack: NSObject, NSCoding {
    
    var isCurrent: Bool = false
    var name: String = ""
    var trackers: [String : Tracker] = [:]
    var checklist: [String: Checklist] = [:]
    var image: UIImage?
    var hasDefaultImage: Bool = true
    
    init(stackName: String){
        name = stackName
    }
    
    init(stackName: String, stackIsCurrent: Bool, stackTrackers:[String:Tracker], stackChecklist:[String:Checklist], stackImage: UIImage?, stackHasDefaultImage: Bool){
        name = stackName
        isCurrent = stackIsCurrent
        trackers = stackTrackers
        checklist = stackChecklist
        image = stackImage
        hasDefaultImage = stackHasDefaultImage
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "stackName")
        aCoder.encode(isCurrent, forKey: "stackIsCurrent")
        aCoder.encode(trackers, forKey: "stackTrackers")
        aCoder.encode(checklist, forKey: "stackChecklist")
        aCoder.encode(image, forKey: "stackImage")
        aCoder.encode(hasDefaultImage, forKey: "stackHasDefaultImage")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "stackName") as! String
        let isCurrent = aDecoder.decodeBool(forKey: "stackIsCurrent")
        let trackers = aDecoder.decodeObject(forKey: "stackTrackers") as! [String:Tracker]
        let checklist = aDecoder.decodeObject(forKey: "stackChecklist") as! [String:Checklist]
        var image: UIImage?
        if let dataImage = aDecoder.decodeObject(forKey: "stackImage") as? UIImage {
            image = dataImage
        }
        let hasDefaultImage = aDecoder.decodeBool(forKey: "stackHasDefaultImage")
        self.init(stackName: name, stackIsCurrent: isCurrent, stackTrackers:trackers, stackChecklist:checklist, stackImage: image, stackHasDefaultImage: hasDefaultImage)
    }
}
