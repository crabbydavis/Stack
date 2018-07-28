//
//  AppDelegate.swift
//  Location
//
//  Created by Davis Crabb on 3/7/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?// = WallpaperWindow()
    let defaults = UserDefaults.standard
    // For Logging Purposes
    let stderr1 = FileHandle.standardError

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        // Override point for customization after application launch.
        //HomeViewController.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        UIApplication.shared.statusBarStyle = .lightContent
        
        print("Opening path for logging")
        redirectLogToDocuments()
        
        LocationManager.SharedManager.initialized = true
        
        print("*** Trying to print launchOptions ***")
        if let launchingOptions = launchOptions {
            for (launchKey, value) in launchingOptions{
                print("Launch options key: \(launchKey) and value: \(value)")
            }
        }
        
        loadStackManager()
        
        return true
    }
    
    func redirectLogToDocuments() {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory.appendingFormat("/testingLogs1.txt")
        freopen(pathForLog.cString(using: .utf8)!, "a+", stderr)
        
        log(logString: "Start! " + "\(Date())\n")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        /*
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: Trackers.sharedTrackers)
        defaults.set(encodedData, forKey: "Trackers")
        defaults.set(Trackers.inGeofence, forKey: "inGeofence")
        UserDefaults.standard.synchronize()
         */
        log(logString: "in applicationWillResignActive");
        saveStackManager()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        /*
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: Trackers.sharedTrackers)
        defaults.set(encodedData, forKey: "Trackers")
        defaults.set(Trackers.inGeofence, forKey: "inGeofence")
        UserDefaults.standard.synchronize()
         */
        log(logString: "in applicationDidEnterBackground");
        saveStackManager()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        /*
        if let decoded  = UserDefaults.standard.object(forKey: "Trackers") as? Data {
            if let decodedTrackers = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [String : Tracker] {
                Trackers.sharedTrackers = decodedTrackers
                Trackers.inGeofence = defaults.bool(forKey: "inGeofence")
            }
        }
        */
        log(logString: "in applicationWillEnterForeground");
        loadStackManager()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /*
        if let decoded  = UserDefaults.standard.object(forKey: "Trackers") as? Data {
            if let decodedTrackers = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [String : Tracker] {
                Trackers.sharedTrackers = decodedTrackers
                Trackers.inGeofence = defaults.bool(forKey: "inGeofence")
            }
        }
         */
        log(logString: "in applicationDidBecomeActive");
        loadStackManager()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //defaults.set(StacksManager, forKey: "StacksManager")
        saveStackManager()
    }

    func saveStackManager(){
        log(logString: "**Saving StackManager**")
        let encodedStacks = NSKeyedArchiver.archivedData(withRootObject: StacksManager.stacks)
        let encodedGeofences = NSKeyedArchiver.archivedData(withRootObject: StacksManager.geofences)
        defaults.set(encodedStacks, forKey: "Stacks")
        defaults.set(encodedGeofences, forKey: "Geofences")
        UserDefaults.standard.synchronize()
    }
    
    func loadStackManager(){
        log(logString: "**Loading StackManager**")
        if let decodedStacksData  = UserDefaults.standard.object(forKey: "Stacks") as? Data {
            if let decodedStacks = NSKeyedUnarchiver.unarchiveObject(with: decodedStacksData) as? [String : Stack] {
                StacksManager.stacks = decodedStacks
            }
        }
        if let decodedGeofencesData  = UserDefaults.standard.object(forKey: "Geofences") as? Data {
            if let decodedGeofences = NSKeyedUnarchiver.unarchiveObject(with: decodedGeofencesData) as? [String : Geofence] {
                StacksManager.geofences = decodedGeofences
            }
        }
    }
    
    func log(logString: String){
        let newString = logString + "\n"
        stderr1.write(newString.data(using: .utf8)!) // log to a file
        print(logString) // log to the console
    }
}

