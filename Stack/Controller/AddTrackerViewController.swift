//
//  AddTrackerViewController.swift
//  Stack
//
//  Created by Davis Crabb on 5/22/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import CoreLocation
import CoreBluetooth

class ConnectTrackerViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    
    var centralManager: CBCentralManager?
    var trackerPeripheral: CBPeripheral?
    let locationManager:CLLocationManager = CLLocationManager()
    var major: CLBeaconMajorValue?
    var minor: CLBeaconMinorValue?
    var timer = Timer()
    
    @IBAction func connectButton(_ sender: UIButton) {
        SVProgressHUD.show()
        //scanForBeacons()
        rangeForBeacons()
    }
    /*
    func scanForBeacons(){
        let miniBeaconService = CBUUID(string: "FFF0")
        centralManager?.scanForPeripherals(withServices: [miniBeaconService], options: nil)
        print("Start Scanning")
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(ConnectTrackerViewController.stopScan)), userInfo: "", repeats: false)
    }
    */
    func rangeForBeacons(){
        let beaconUUID = UUID.init(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let region = CLBeaconRegion(proximityUUID: beaconUUID!, identifier: "ChineseBeacons")
        locationManager.startRangingBeacons(in: region)
    }
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBluetooth()
        setupLocationManager()
    }
    
    func setupBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
    }
    
    @objc func stopScan(timer : Timer) {
        //let date = Date()
        //print("Timer Ended: \(date)  Beacon Identifier: \(beaconIdentifier)  Nearby: \(Trackers.sharedTrackers[beaconIdentifier]!.nearby)")
        timer.invalidate()
        centralManager?.stopScan()
        SVProgressHUD.dismiss()
        // If we find a tracker then move to the next screen
        //performSegue(withIdentifier: "connectedTracker", sender: self)
    }
    
    // MARK: - Core Bluetooth Delegate Methods
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Peripheral: \(peripheral)")
        print("Advertisement Data: \(advertisementData)")
        print("RSSI: \(RSSI)")
        trackerPeripheral = peripheral
        if let tracker = trackerPeripheral {
            tracker.delegate = self
            centralManager?.connect(tracker, options: nil)
            centralManager?.stopScan()
            SVProgressHUD.dismiss()
        }
        
        // Use the following for our dev board
        if peripheral.name == "stack-setup" {
            if let uuid = advertisementData["kCBAdvDataServiceData"] {
                print("Beacon UUID: \(uuid)")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect")
        print(peripheral)
        // STEP 8: look for services of interest on peripheral
        let miniBeaconService = CBUUID(string: "FFF0")
        //peripheral.discoverServices([miniBeaconService])
        peripheral.discoverServices(nil)

        //peripheral?.discoverServices([BLE_Heart_Rate_Service_CBUUID])
    }
    
    // Must have this method for the View Controller to inherit CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Do something
    }
    
    // MARK: - Peripheral Delegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("Service: \(service)")
                //let deviceInfo = CBUUID(string: "Device Information")
                print("*******Found Device Information*******")
                peripheral.discoverCharacteristics(nil, for: service)
                //if(service.uuid == deviceInfo){
                    
                //}
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("Error: \(err) for service: \(service)")
        }
        if let characteristics = service.characteristics {
            for characteric in characteristics {
                print("Characteristics: \(characteric)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor Characteristic: \(characteristic)")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor Characteristic: \(characteristic)")
    }
    
    // MARK: - Location Delegate Methods
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("Determined state for region")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("In didRangeBeacons")
        if beacons.count > 0 {
            let nearestBeacon = beacons.first!
            major = CLBeaconMajorValue(truncating: nearestBeacon.major)
            minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)
            
            print("Major: \(major!)")
            print("Minor: \(minor!)")
            
            locationManager.stopRangingBeacons(in: region)
            SVProgressHUD.dismiss()
            
            performSegue(withIdentifier: "connectedTracker", sender: self)
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connectedTracker" {
            let addTrackerVC = segue.destination as! AddTrackerViewController
            addTrackerVC.minor = minor
            addTrackerVC.major = major
        }
    }
}

class AddTrackerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    enum ItemType{ case Tracker, Checklist }
    
    @IBOutlet weak var stackTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var stacks = [String]() //["Snowboard", "Baby", "Camping", "General"]
    var pickerView = UIPickerView()
    var defaultStack = ""
    var item = ItemType.Tracker
    var gotPhoto: Bool = false
    var itemName: String = ""
    var major: CLBeaconMajorValue?
    var minor: CLBeaconMinorValue?
    let locationManager:CLLocationManager = CLLocationManager()

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func goToCamera(_ sender: UIButton) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.cameraButton.setImage(image, for: .normal)
            self.gotPhoto = true
        }
    }
    
    @IBAction func switchType(_ sender: UIButton) {
        if item == ItemType.Tracker {
            item = ItemType.Checklist
            saveButton.setTitle("Save Checklist", for: .normal)
            switchButton.setTitle("Switch to Tracker Item", for: .normal)
        } else {
            item = ItemType.Tracker
            saveButton.setTitle("Save Tracker", for: .normal)
            switchButton.setTitle("Switch to Checklist Item", for: .normal)
        }
    }
    
    @IBAction func saveItem(_ sender: UIButton) {
        if item == ItemType.Tracker {
            //let tracker = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconIdentifier: nameTextField.text!, beaconNearby: true)
            let tracker = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconMajor: major!, beaconMinor: minor!, beaconIdentifier: nameTextField.text!, beaconNearby: true)
            locationManager.startMonitoring(for: tracker.beaconRegion)
            if gotPhoto {
                if let trackerImage = cameraButton.image(for: .normal){
                    tracker.image = trackerImage
                }
            }
            // Start monitoring the region
            StacksManager.stacks[stackTextField.text!]?.trackers.updateValue(tracker, forKey: nameTextField.text!)
        } else {
            let checklist = Checklist(checklistName: nameTextField.text!)
            if gotPhoto {
                if let checklistImage = cameraButton.image(for: .normal){
                    checklist.image = checklistImage
                }
            }
            StacksManager.stacks[stackTextField.text!]?.checklist.updateValue(checklist, forKey: nameTextField.text!)
        }
        performSegue(withIdentifier: "saveItem", sender: self)
    }
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        
        for (identifier, _) in StacksManager.stacks{
            stacks.append(identifier)
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        
        stackTextField.inputView = pickerView
        for (identifier, _) in StacksManager.stacks {
            defaultStack = identifier
        }
        stackTextField.text = defaultStack
        
        nameTextField.delegate = self
        nameTextField.text = itemName
        
        initUI()
    }
    
    func initUI(){
        nameView.layer.borderWidth = 1
        nameView.layer.borderColor = UIColor.white.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name of item",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.white.cgColor
        
        cameraButton.layer.cornerRadius = 71.5
        cameraButton.layer.masksToBounds = true
        
        
    }
    
    // MARK: - Picker View Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stacks.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stacks[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stackTextField.text = stacks[row]
        stackTextField.resignFirstResponder()
    }
    
    //////////////////////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //bottomView.backgroundColor = UIColor.black
        
        UIView.animate(withDuration: 0.5){
            //self.bottomViewTopConstraint.constant = -100
            //self.textFieldTopConstraint.constant = self.textFieldTopConstraint.constant - 65
            //self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        //bottomView.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.5){
            //self.bottomViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
        return true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveItem" {
            let stackDetailsVC = segue.destination as! StackDetailsViewController
            stackDetailsVC.stackName = stackTextField.text!
        }
    }
}
