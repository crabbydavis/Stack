//
//  AddStackViewController.swift
//  Stack
//
//  Created by Davis Crabb on 5/27/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class AddStackViewController: UIViewController, UITextFieldDelegate {
    
    var gotPhoto: Bool = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var photoButton: UIButton!
    @IBAction func getPhoto(_ sender: UIButton) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.photoButton.setImage(image, for: .normal)
            self.photoButton.contentMode = .center
            self.gotPhoto = true
        }
    }
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func createStack(_ sender: UIButton) {
        
        if let stackName = nameTextField.text {
            let newStack: Stack = Stack(stackName: stackName)
            if gotPhoto {
                if let stackImage = photoButton.image(for: .normal) {
                    newStack.image = stackImage
                }
            }
            StacksManager.stacks.updateValue(newStack, forKey: stackName)
            
            performSegue(withIdentifier: "showStackDetails", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        initUI()
    }
    
    func initUI(){
        nameView.layer.borderWidth = 1
        nameView.layer.borderColor = UIColor.white.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name of Stack",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        photoButton.layer.cornerRadius = 71.5
        photoButton.layer.masksToBounds = true
    }
    
    //////////////////////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //bottomView.backgroundColor = UIColor.black
        
        UIView.animate(withDuration: 0.5){
            self.bottomViewTopConstraint.constant = -100
            //self.textFieldTopConstraint.constant = self.textFieldTopConstraint.constant - 65
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        //bottomView.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.5){
            self.bottomViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
        return true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStackDetails" {
            let stackDetailsVC = segue.destination as! StackDetailsViewController
            stackDetailsVC.stackName = nameTextField.text!
        }
    }
}
