//
//  SettingsViewController.swift
//  Stack
//
//  Created by Davis Crabb on 5/20/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit
// Imports for notifications
import UserNotifications
import Toaster
// Imports to monitor beacons
import CoreLocation
import AVFoundation
import CoreBluetooth

class SettingsViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    /*
    var database: DatabaseReference!
    let locationManager:CLLocationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var timer = Timer()
    var player: AVAudioPlayer?
    var startTime: DispatchTime?
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var BodyTextField: UITextField!
    @IBOutlet weak var TimeTextField: UITextField!
    
    @IBAction func sendNotification(_ sender: UIButton) {
        
        // This fires in some amount of seconds
        let time:Int? = Int(TimeTextField.text!)
        
        sendNotification(title: TitleTextField.text!, body: BodyTextField.text!, time: time!)
        ToastView.appearance().bottomOffsetPortrait = CGFloat(UIScreen.main.bounds.height * 0.5)
        ToastView.appearance().font = UIFont.systemFont(ofSize: 20)//UIFont(descriptor: "Roboto", size: 20)
        ToastView.appearance().backgroundColor = UIColor(red:0.12, green:0.76, blue:0.65, alpha:1.0)//1FC3A6
        ToastView.appearance().textColor = UIColor.white
        let toast = Toast(text: "Notification Queued", duration: Delay.short)
        toast.show()
    }
    
    
    @IBAction func monitorBeacons(_ sender: UIButton) {
        monitorBeaconRegions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        TitleTextField.delegate = self
        BodyTextField.delegate = self
        TimeTextField.delegate = self
        
        //setupLocationManager()
        database = Database.database().reference() // Initialize the db reference
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
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() // Requesting to always have access to location
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation() // Starts asking for the location
        locationManager.distanceFilter = 50 // Only updates if distance has changed by 10m
        print("Regions currently monitored:")
        for region in locationManager.monitoredRegions {
            print("\(region)")
        }
    }
    
    // MARK: - Beacon Section
    func monitorBeaconRegions() {
        
        // Create Trackers
        let circleTracker1 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE61", beaconMajor: 1, beaconMinor: 1, beaconIdentifier: "Beacon 1", beaconNearby: true)
        let circleTracker2 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE62", beaconMajor: 1, beaconMinor: 2, beaconIdentifier: "Beacon 2", beaconNearby: true)
        let circleTracker3 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE63", beaconMajor: 1, beaconMinor: 3, beaconIdentifier: "Beacon 3", beaconNearby: true)
        let circleTracker4 = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE64", beaconMajor: 1, beaconMinor: 4, beaconIdentifier: "Beacon 4", beaconNearby: true)
        
        // Add trackers to the shared trackers
        Trackers.sharedTrackers.updateValue(circleTracker1, forKey: circleTracker1.beaconRegion.identifier)
        Trackers.sharedTrackers.updateValue(circleTracker2, forKey: circleTracker2.beaconRegion.identifier)
        Trackers.sharedTrackers.updateValue(circleTracker3, forKey: circleTracker3.beaconRegion.identifier)
        Trackers.sharedTrackers.updateValue(circleTracker4, forKey: circleTracker4.beaconRegion.identifier)

        // Monitor the trackers
        locationManager.startMonitoring(for: circleTracker1.beaconRegion)
        locationManager.startMonitoring(for: circleTracker2.beaconRegion)
        locationManager.startMonitoring(for: circleTracker3.beaconRegion)
        locationManager.startMonitoring(for: circleTracker4.beaconRegion)
    }
    
    func logToFirebase(identifier: String, event: String){
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let dbSpot = database.childByAutoId()
        
        if let start = startTime {
            let nanoTime = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Int(nanoTime) / 1_000_000_000 // Technically could overflow for long running
            dbSpot.setValue(["\(day)-\(month)-\(year) \(hour):\(minutes) \(event)-\(identifier)":"\(timeInterval)"])
            print("Going to set value in DB")
        } else {
            dbSpot.setValue(["\(day)-\(month)-\(year) \(hour):\(minutes) \(identifier)":"\(event)"])
            print("Going to set value in DB")
        }
    }
    
    // MARK: - Location Manager Delegate Methods
    // This gets generated after location.requestState
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("didDetermineState: \(state)  for: \(region.identifier)")
        print("Raw Value \(state.rawValue)")
        print("Hash Value \(state.hashValue)")
        let date = Date()
        print("Determined State at Time: \(date)")
        
        // See if the determined state was for a geofence
        if let geofence = StacksManager.geofences[region.identifier] {
            if(state.rawValue == 1){
                geofence.inGeofence = true
            } else {
                geofence.inGeofence = false
            }
        }
        // See if the determined state was for a tracker
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[region.identifier] {
                if(state.rawValue == 1){
                    tracker.nearby = true
                } else {
                    tracker.nearby = false
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let failedRegion = region {
            print("Monitoring Regions \(failedRegion) Failed!!")
            print("Error: \(error)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring for region: \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered \(region.identifier)")
        //logToFirebase(identifier: region.identifier, event: "Enter")

        if let geofence = StacksManager.geofences[region.identifier] {
            geofence.inGeofence = true
        }
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[region.identifier] {
                tracker.nearby = true
                logToFirebase(identifier: region.identifier, event: "Enter")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("region identifier \(region.identifier)")
        logToFirebase(identifier: region.identifier, event: "Exit")
        
        // Check to see if the region is a Geofence
        if let geofence = StacksManager.geofences[region.identifier] {
            geofence.inGeofence = false
            for (_, stack) in StacksManager.stacks {
                for(identifier, tracker) in stack.trackers {
                    if(tracker.nearby == false){
                        sendNotification(title: "You Left \(identifier)", body: "Left Item Behind", time: 1)
                    }
                }
            }
        }
        // Check to see if the region is an iBeacon
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[region.identifier] {
                tracker.nearby = false
                print("Exited \(region.identifier)")
                let date = Date()
                startTime = DispatchTime.now()
                print("Exited: \(date)")
                if(StacksManager.geofences.count == 0){
                    print("No Geofence")
                    timer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: (#selector(SettingsViewController.debounceEvent)), userInfo: region.identifier, repeats: false)
                } else {
                    // Check to make sure user isn't in any geofences
                    var inGeofence = false;
                    for(_ , geofence) in StacksManager.geofences{
                        if(geofence.inGeofence == true){
                            inGeofence = true;
                        }
                    }
                    if(!inGeofence){
                        print("inGeofence False")
                        timer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: (#selector(SettingsViewController.debounceEvent)), userInfo: region.identifier, repeats: false)
                    }
                }
            }
        }
    }
    
    @objc func debounceEvent(timer : Timer) {
        let identifier = timer.userInfo as? String ?? ""
        timer.invalidate()
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[identifier] {
                if(tracker.nearby == false){
                    logToFirebase(identifier: identifier, event: "Send Notification")
                    sendNotification(title: "You Left \(identifier)", body: "Left Item Behind", time: 1)
                }
            }
        }
    }
    
    func checkBeacons() {
        print("In checkBeacons")
        for (identifier, tracker) in Trackers.sharedTrackers {
            print("The identifier for \(tracker) is \(identifier)")
            if (!tracker.nearby) {
                sendNotification(title: "You Left \(identifier)", body: "Left Item Behind", time: 1)
            }
        }
    }
    
    func sendNotification(title: String, body: String, time: Int) {
        print("In send notification")

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body,
            arguments: nil)
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
        
        // Create the request object.
        let date = Date().description
        let request = UNNotificationRequest(identifier: date, content: content, trigger: trigger)
        notificationCenter.add(request) // Schedule the request.
        //makeSound()
    }
    
    // MARK: - Sound
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
    
    //MARK:- TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        TitleTextField.endEditing(true)
        BodyTextField.endEditing(true)
        TimeTextField.endEditing(true)
        return true
    }*/
}
