//
//  Geofence.swift
//  Stack
//
//  Created by Davis Crabb on 5/28/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import CoreLocation

class Geofence: NSObject, NSCoding {
    
    var inGeofence: Bool
    var region: CLCircularRegion
    
    init(insideGeofence: Bool, circularRegion: CLCircularRegion) {
        inGeofence = insideGeofence
        region = circularRegion
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(inGeofence, forKey: "inGeofence")
        aCoder.encode(region, forKey: "region")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let inGeofence = aDecoder.decodeBool(forKey: "inGeofence")
        let region = aDecoder.decodeObject(forKey: "region") as! CLCircularRegion
        self.init(insideGeofence: inGeofence, circularRegion: region)
    }
}
