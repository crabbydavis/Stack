//
//  Tracker.swift
//  Location
//
//  Created by Davis Crabb on 4/4/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Tracker: NSObject, NSCoding {
    
    var nearby: Bool
    var beaconRegion: CLBeaconRegion
    var image: UIImage?

    init(uuidString: String, beaconMajor: UInt16, beaconMinor: UInt16, beaconIdentifier: String, beaconNearby: Bool) {
        let beaconUUID = UUID.init(uuidString: uuidString)
        beaconRegion =  CLBeaconRegion(proximityUUID: beaconUUID!, major: beaconMajor, minor: beaconMinor, identifier: beaconIdentifier)
        nearby = beaconNearby
    }
    
    init(uuidString: String, beaconIdentifier: String, beaconNearby: Bool) {
        let beaconUUID = UUID.init(uuidString: uuidString)
        beaconRegion =  CLBeaconRegion(proximityUUID: beaconUUID!, identifier: beaconIdentifier)
        nearby = beaconNearby
    }
    
    init(uuidString: String, beaconMajor: UInt16, beaconIdentifier: String, beaconNearby: Bool) {
        let beaconUUID = UUID.init(uuidString: uuidString)
        beaconRegion =  CLBeaconRegion(proximityUUID: beaconUUID!, major: beaconMajor, identifier: beaconIdentifier)
        nearby = beaconNearby
    }
    
    init(region: CLBeaconRegion, beaconNearby: Bool){
        beaconRegion = region
        nearby = beaconNearby
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let nearby = aDecoder.decodeBool(forKey: "nearby")
        let beaconRegion = aDecoder.decodeObject(forKey: "beaconRegion") as! CLBeaconRegion
        self.init(region: beaconRegion, beaconNearby: nearby)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(nearby, forKey: "nearby")
        aCoder.encode(beaconRegion, forKey: "beaconRegion")
    }
}

/*
 let start = DispatchTime.now() // <<<<<<<<<< Start time
 let myGuess = problemBlock()
 let end = DispatchTime.now()   // <<<<<<<<<<   end time
 
 let theAnswer = self.checkAnswer(answerNum: "\(problemNumber)", guess: myGuess)
 
 let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
 let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
 */
