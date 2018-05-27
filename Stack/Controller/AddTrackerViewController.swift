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

class ConnectTrackerViewController: UIViewController {
    
    @IBAction func connectButton(_ sender: UIButton) {
        SVProgressHUD.show()
        //sleep(3)
        SVProgressHUD.dismiss()
        performSegue(withIdentifier: "connectedTracker", sender: self)
    }
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class AddTrackerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var stackTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    let stacks = ["Snowboard", "Baby", "Camping", "General"]
    var pickerView = UIPickerView()
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var stackView: UIView!
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        stackTextField.inputView = pickerView
        
        initUI()
    }
    
    func initUI(){
        nameView.layer.borderWidth = 1
        nameView.layer.borderColor = UIColor.white.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name of item",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.white.cgColor
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
}
