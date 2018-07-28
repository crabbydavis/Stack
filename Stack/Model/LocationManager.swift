//
//  LocationManager.swift
//  Stack
//
//  Created by Davis Crabb on 7/14/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import UIKit
import Firebase
import AVFoundation


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let SharedManager = LocationManager()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var database: DatabaseReference!
    let locationManager:CLLocationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var timer = Timer()
    var player: AVAudioPlayer?
    var startTime: DispatchTime?
    var initialized: Bool = false
    let dateFormatter = DateFormatter()
    
    // For Logging Purposes
    let stderr1 = FileHandle.standardError
    
    override init() {
        super.init()
        print("Initializing the Location Manager")
        
        // Init the date formatter
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        setupNotifications()
        setupLocationManager()
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
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .other
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The service is not available.
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
        print("Regions currently monitored:")
        for region in locationManager.monitoredRegions {
            print("\(region)")
        }
    }
    
    // MARK: - Logging
    func log(logString: String){
        stderr1.write(logString.data(using: .utf8)!) // log to a file
        print(logString) // log to the console
    }
    
    func logToFile(logString: String){
        stderr1.write(logString.data(using: .utf8)!)
    }
    
    func logToFirebase(identifier: String, event: String){
        /*
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
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
        dbSpot.setValue(["\(day)-\(month)-\(year) \(hour):\(minutes):\(seconds) \(identifier)":"\(event)"])*/
        //}
    }
    
    // MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        log(logString: "Significant location change at \(dateFormatter.string(from: lastLocation.timestamp))")
        
        // Find all trackers that aren't neaby
        // See if the determined state was for a tracker
        for (_, stack) in StacksManager.stacks {
            var missingTrackers = [String]()
            for (name, tracker) in stack.trackers {
                if(!tracker.nearby){
                    missingTrackers.append(name)
                }
            }
            // Don't notify the user if more than half of the stacks are missing
            if(missingTrackers.count > stack.trackers.count / 2){
                continue
            } else {
                var notificationString = "Missing: "
                for name in missingTrackers {
                    notificationString += name
                    if(name != missingTrackers.last){
                        notificationString += ", "
                    }
                }
                sendNotification(title: "\(dateFormatter.string(from: lastLocation.timestamp))", body: notificationString, time: 1)
            }
        }
        
    }
    
    // This gets generated after location.requestState
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("didDetermineState: \(state)  for: \(region.identifier)")
        print("Raw Value \(state.rawValue)")
        print("Hash Value \(state.hashValue)")
        let date = Date()
        print("Determined State at Time: \(date)")
        
        // For logging
        //logToFile(logString: "\(Date()) : DidDetermineState : \(region.identifier) - \(state.rawValue) \n")
        
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
        // For logging
        logToFirebase(identifier: region.identifier, event: "EnterRegion")
        log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : EnterRegion\n")
        
        if let geofence = StacksManager.geofences[region.identifier] {
            geofence.inGeofence = true
        }
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[region.identifier] {
                tracker.nearby = true
                logToFirebase(identifier: region.identifier, event: "EnterRegion - set tracker.nearby to true")
                log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : EnterRegion - set tracker.nearby to true\n")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let timerLength: Double = 30
        
        // For logging
        logToFirebase(identifier: region.identifier, event: "ExitRegion")
        log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : ExitRegion\n")
        
        // Check to see if the region is a Geofence
        if let geofence = StacksManager.geofences[region.identifier] {
            geofence.inGeofence = false
            for (_, stack) in StacksManager.stacks {
                for(identifier, tracker) in stack.trackers {
                    if(tracker.nearby == false){
                        sendNotification(title: "You Left \(identifier)", body: "Left Item Behind", time: 1)
                        log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : ExitRegion - send notification because of geofence\n")
                        logToFirebase(identifier: region.identifier, event: "ExitRegion - send notification because of geofence")
                    }
                }
            }
        } else {
            log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : Region couldn't be found in Geofences\n")
            logToFirebase(identifier: region.identifier, event: "Region couldn't be found in Geofences")
        }
        log(logString: "Num Stacks: \(StacksManager.stacks.count)\n")
        // Check to see if the region is an iBeacon
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[region.identifier] {
                tracker.nearby = false
                let date = Date()
                startTime = DispatchTime.now()
                if(StacksManager.geofences.count == 0){
                    log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : ExitRegion - no geofences, start timer\n")
                    logToFirebase(identifier: region.identifier, event: "ExitRegion - no geofences, start timer")
                    registerBackgroundTask() // Start a background task to ensure we can send the notification
                    timer = Timer.scheduledTimer(timeInterval: timerLength, target: self, selector: (#selector(LocationManager.debounceEvent)), userInfo: region.identifier, repeats: false)
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
                        log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : ExitRegion - not in geofence, start timer\n")
                        logToFirebase(identifier: region.identifier, event: "ExitRegion - no geofences, start timer")
                        registerBackgroundTask() // Start a background task to ensure we can send the notification
                        timer = Timer.scheduledTimer(timeInterval: timerLength, target: self, selector: (#selector(LocationManager.debounceEvent)), userInfo: region.identifier, repeats: false)
                    }
                }
            } else {
                log(logString: "\(dateFormatter.string(from: Date())) : \(region.identifier) : Region couldn't be found in Trackers\n")
                logToFirebase(identifier: region.identifier, event: "Region couldn't be found in Trackers")
            }
        }
    }
    
    @objc func debounceEvent(timer : Timer) {
        let identifier = timer.userInfo as? String ?? ""
        log(logString: "\(dateFormatter.string(from: Date())) : \(identifier) : ExitRegion - end timer \n")
        logToFirebase(identifier: identifier, event: "ExitRegion - end timer")

        timer.invalidate()
        for (_, stack) in StacksManager.stacks {
            if let tracker = stack.trackers[identifier] {
                if(tracker.nearby == false){
                    log(logString: "\(dateFormatter.string(from: Date())) : \(identifier) : Send Notification \n")
                    logToFirebase(identifier: identifier, event: "Send Notification")
                    sendNotification(title: "You Left \(identifier)", body: "Left Item Behind", time: 1)
                }
            }
        }
        endBackgroundTask()
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
        
        log(logString: "\(dateFormatter.string(from: Date())) : Add Notification Request \n")
        logToFirebase(identifier: title, event: "Add Notification Request")

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
    
    // MARK: - Background Task
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}
