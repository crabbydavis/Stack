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

class ConnectTrackerViewController: UIViewController {
    
    @IBAction func connectButton(_ sender: UIButton) {
        //SVProgressHUD.show()
        //sleep(3)
        //SVProgressHUD.dismiss()
        performSegue(withIdentifier: "connectedTracker", sender: self)
    }
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class AddTrackerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    enum ItemType{ case Tracker, Checklist }
    
    @IBOutlet weak var stackTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var stacks = [String]() //["Snowboard", "Baby", "Camping", "General"]
    var pickerView = UIPickerView()
    var defaultStack = ""
    var item = ItemType.Tracker
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func goToCamera(_ sender: UIButton) {
        CameraHandler.shared.showActionSheet(vc: self)
        //CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.cameraButton.setImage(image, for: .normal)
        }
    }
    
    @IBAction func switchType(_ sender: UIButton) {
        if item == ItemType.Tracker {
            item = ItemType.Checklist
            saveButton.titleLabel?.text = "Save Checklist"
            switchButton.titleLabel?.text = "Switch to Tracker Item"
        } else {
            item = ItemType.Tracker
            saveButton.titleLabel?.text = "Save Tracker"
            switchButton.titleLabel?.text = "Switch to Checklist Item"
        }
    }
    
    @IBAction func saveItem(_ sender: UIButton) {
        if item == ItemType.Tracker {
            let tracker = Tracker(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", beaconIdentifier: nameTextField.text!, beaconNearby: true)
            // Start monitoring the region
            StacksManager.stacks[stackTextField.text!]?.trackers.updateValue(tracker, forKey: nameTextField.text!)
            
        } else {
            let checklist = Checklist(checklistName: nameTextField.text!)
            StacksManager.stacks[stackTextField.text!]?.checklist.updateValue(checklist, forKey: nameTextField.text!)
        }
        performSegue(withIdentifier: "saveItem", sender: self)
    }
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
