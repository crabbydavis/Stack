//
//  Geofence.swift
//  Stack
//
//  Created by Davis Crabb on 5/28/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import CoreLocation

class Geofence {
    
    var inGeofence: Bool
    var region: CLCircularRegion
    
    init(insideGeofence: Bool, circularRegion: CLCircularRegion) {
        inGeofence = insideGeofence
        region = circularRegion
    }
}
