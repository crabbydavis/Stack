//
//  ViewController.swift
//  Location
//
//  Created by Davis Crabb on 3/7/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//
/**
 This is the controller for my project. The most interesting part of this code is probably the exit event which can be found on line 173 - func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
 The os calls this function when a beacon that the phone is monitoring exits the phones bluetooth radius. From here you can follow the logic to see that I have a 5 second timer to debounce the event and make sure the beacon has exited as well as send notifications for the beacson that aren't neaby.
 */

import UIKit
import CoreLocation
import UserNotifications
import AVFoundation
import CoreBluetooth
//import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    let locationManager:CLLocationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var timer = Timer()
    var player: AVAudioPlayer?
    var startTime: DispatchTime?
    //var database: DatabaseReference!
    var gotLocation: Bool = false

    @IBOutlet weak var geofenceLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBAction func startScanButton(_ sender: UIButton) {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    @IBAction func stopScanButton(_ sender: UIButton) {
        centralManager?.stopScan()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupNotifications()
        monitorGeofence()
        monitorBeaconRegion()
        geofenceLabel.text = "Setup"
        setupBluetooth()
        activateAudio()
        //database = Database.database().reference() // Initialize the db reference
    }
    
    func setupBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral: \(peripheral)")
        print("Advertisement Data: \(advertisementData)")
        print("RSSI: \(RSSI)")
        if peripheral.name == "stack-setup" {
            if let uuid = advertisementData["kCBAdvDataServiceData"] {
                print("Beacon UUID: \(uuid)")
            }
        }
    }
    
    // Must have this method for the View Controller to inherit CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Do something
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() // Requesting to always have access to location
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation() // Starts asking for the location
        locationManager.distanceFilter = 30 // Only updates if distance has changed by 10m
    }
    
    func setupNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func monitorGeofence(){
        let geoFenceRegion1: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(40.234844, -111.677165), radius: 30, identifier: "DavisHomeGeofence") // My House
        let geoFenceRegion2: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(40.551434, -111.840826), radius: 30, identifier: "ParkerHomeGeofence") // Parker's House
        locationManager.startMonitoring(for: geoFenceRegion1)
        locationManager.requestState(for: geoFenceRegion1) // Forces location Manager to fire event
        locationManager.startMonitoring(for: geoFenceRegion2)
        locationManager.requestState(for: geoFenceRegion2) // Forces location Manager to fire event
    }
    
    func monitorBeaconRegion() {
        //let tracker1 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 8725, beaconMinor: 7, beaconIdentifier: "charger", beaconNearby: true)
        //let tracker2 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 8725, beaconMinor: 2, beaconIdentifier: "blueberry", beaconNearby: false)
        //let tracker3 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 8725, beaconMinor: 1, beaconIdentifier: "home", beaconNearby: true)
        //let tracker4 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 8725, beaconMinor: 5, beaconIdentifier: "bike", beaconNearby: true)
        //let tracker5 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 8725, beaconMinor: 11, beaconIdentifier: "door", beaconNearby: true)
        
        let circleTracker1 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 1, beaconMinor: 1, beaconIdentifier: "backpack", beaconNearby: true)
        let circleTracker2 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 1, beaconMinor: 2, beaconIdentifier: "charger", beaconNearby: true)
        let circleTracker3 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: 1, beaconMinor: 3, beaconIdentifier: "keys", beaconNearby: true)
        
        // Add trackers to the shared trackers
        Trackers.sharedTrackers.updateValue(circleTracker1, forKey: circleTracker1.beaconRegion.identifier)
        Trackers.sharedTrackers.updateValue(circleTracker2, forKey: circleTracker2.beaconRegion.identifier)
        Trackers.sharedTrackers.updateValue(circleTracker3, forKey: circleTracker3.beaconRegion.identifier)

        // Monitor the trackers
        locationManager.startMonitoring(for: circleTracker1.beaconRegion)
        locationManager.startMonitoring(for: circleTracker2.beaconRegion)
        locationManager.startMonitoring(for: circleTracker3.beaconRegion)
    }
    
    // MARK: - Location Manager
    // This locations array usually only has 1 location in it, but sometimes it'll have 2
    // The last location in the array will be the most accurate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            print("\(index): \(currentLocation)")
            /*
             if gotLocation == false {
             print("Creating Geofence")
             let geoFenceRegion: CLCircularRegion = CLCircularRegion(center: currentLocation.coordinate, radius: 10, identifier: "Home") // radius is in meters
             locationManager.startMonitoring(for: geoFenceRegion)
             gotLocation = true
             }
             */
        }
    }
    
    // This gets generated after location.requestState
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("didDetermineState: \(state)  for: \(region.identifier)")
        print("Raw Value \(state.rawValue)")
        print("Hash Value \(state.hashValue)")
        let date = Date()
        print("Determined State at Time: \(date)")
        if gotLocation == false {
            gotLocation = true
            if region.identifier == "DavisHomeGeofence" || region.identifier == "ParkerHomeGeofence" {
                // Raw and Hash value 2 for outside geofence
                if state.rawValue == 2 {
                    print("Setting inGeofence to false")
                    Trackers.inGeofence = false
                } else {
                    print("Setting inGeofence to true")
                    Trackers.inGeofence = false
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered \(region.identifier)")
        if region.identifier == "DavisHomeGeofence" || region.identifier == "ParkerHomeGeofence" {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            //database.child("enteredHomeGeofence").setValue(["hour": hour, "minute":minutes])
            Trackers.inGeofence = true
            locationManager.distanceFilter = 30
            geofenceLabel.text = "Inside"
        } else if region.identifier == "car" {
            geofenceLabel.text = "Entered \(region.identifier)"
            Trackers.sharedTrackers[region.identifier]?.nearby = true
            Trackers.inGeofence = false
            checkBeacons()
        } else {
            let date = Date()
            endLabel.text = "Entered: \(date)"
            geofenceLabel.text = "Entered \(region.identifier)"
            Trackers.sharedTrackers[region.identifier]?.nearby = true

            //if(!Trackers.inGeofence){
                let endTime = DispatchTime.now()
                print("Trying to get the start time")
                if let start = startTime {
                    let nanoTime = endTime.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                    let timeInterval = Int(nanoTime) / 1_000_000_000 // Technically could overflow for long running
                    let date = Date()
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    //database.child("exitToEnterTime")
                    //let dbSpot = database.childByAutoId()
                    //dbSpot.setValue(["\(hour):\(minutes)":"\(timeInterval)"])
                    
                    print("Going to set value in DB")
                    //database.child("exitToEnterTime").child("\(timeInterval)").setValue(["time": timeInterval])
                //}
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited \(region.identifier)")
        let tracker = Trackers.sharedTrackers[region.identifier]!
        
        if region.identifier == "DavisHomeGeofence" || region.identifier == "ParkerHomeGeofence" {
            if(Trackers.inGeofence){
                Trackers.inGeofence = false
                checkBeacons()
            }
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            //database.child("exitedHomeGeofence").setValue(["hour": hour, "minute":minutes])
            locationManager.distanceFilter = 100
            geofenceLabel.text = "Outside"
            
        } else if region.identifier == "car" {
            geofenceLabel.text = "Exited \(region.identifier)"
            tracker.nearby = false
        } else {
            tracker.nearby = false
            geofenceLabel.text = "Exited \(region.identifier)"
            let date = Date()
            startLabel.text = "Exited: \(date)"
            print("Goin")
            //if(!Trackers.inGeofence) {
                print("Setting the start time")
                startTime = DispatchTime.now()
                //locationManager.startRangingBeacons(in: tracker.beaconRegion)
                //print("Started Timer: \(date)  Nearby: \(Trackers.sharedTrackers[region.identifier]!.nearby)")
                timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(ViewController.debounceEvent)), userInfo: region.identifier, repeats: false)
            //}
        }
    }
    
    @objc func debounceEvent(timer : Timer) {
        let beaconIdentifier = timer.userInfo as? String ?? ""
        //let date = Date()
        //print("Timer Ended: \(date)  Beacon Identifier: \(beaconIdentifier)  Nearby: \(Trackers.sharedTrackers[beaconIdentifier]!.nearby)")
        timer.invalidate()
        if let nearby = Trackers.sharedTrackers[beaconIdentifier]?.nearby {
            print("Unwarapped nearby optional and nearby: \(nearby)")
            if nearby == false {
                sendNotification(title: "Notification from Beacon", identifier: beaconIdentifier)
            }
        }
        /*if let beaconRegion = Trackers.sharedTrackers[beaconIdentifier]?.beaconRegion {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }*/
    }
    
    func checkBeacons() {
        print("In checkBeacons")
        for (identifier, tracker) in Trackers.sharedTrackers {
            print("The identifier for \(tracker) is \(identifier)")
            if (!tracker.nearby) {
                sendNotification(title: "notification because of geofence", identifier: identifier)
            }
        }
    }
    
    // MARK: - Notifications
    func sendNotification(title: String, identifier: String) {
        print("In send notification")
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Did you forget your \(identifier)?",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        
        // This fires in 1 second
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "iBeacon", content: content, trigger: trigger)
        notificationCenter.add(request) // Schedule the request.
        
        makeSound()
    }
    
    func activateAudio(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func makeSound() {
        activateAudio()
        guard let url = Bundle.main.url(forResource: "cow1", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            guard let player = player else { return }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
