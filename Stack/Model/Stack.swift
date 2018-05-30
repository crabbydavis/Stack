//
//  Stack.swift
//  Stack
//
//  Created by Davis Crabb on 5/28/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class Stack {
    
    var isCurrent: Bool = false
    var name: String = ""
    var trackers: [String : Tracker] = [:]
    var checklist: [String: Checklist] = [:]
    var image = UIImage()
    
    init(stackName: String){
        name = stackName
    }
}
