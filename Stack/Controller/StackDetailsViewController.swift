//
//  StackDetailsViewController.swift
//  Stack
//
//  Created by Davis Crabb on 5/24/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class StackDetailsViewController: UIViewController {
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBOutlet weak var trackersStackView: UIStackView!
    @IBOutlet weak var checklistStackView: UIStackView!
    @IBOutlet weak var trackersHeight: NSLayoutConstraint!
    @IBOutlet weak var checklistHeight: NSLayoutConstraint!
    var trackers = [String]()//["Gloves","Goggles","Gloves","Goggles"]//,"Boots","Helmet","Snowboard"]
    var checklist = [String]()//["Pass", "Glasses"]
    var stackName: String = ""
    var stack: Stack?
    
    @IBOutlet weak var viewTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let stack = StacksManager.stacks[stackName] {
            for (identifier, _) in  stack.trackers {
                trackers.append(identifier)
            }
            for (identifier, _) in  stack.checklist {
                checklist.append(identifier)
            }
        }
        initUI()
    }
    
    func initUI(){
        // Set the title of the view
        viewTitle.text = stackName
        
        // Set up the stack views
        addItemsToStackView(stackView: trackersStackView, stackHeight: trackersHeight, items: trackers, defaultButtonTitle: "+ Add Tracker")
        addItemsToStackView(stackView: checklistStackView, stackHeight: checklistHeight, items: checklist, defaultButtonTitle: "+ Add Checklist")
    }
    
    func addItemsToStackView(stackView: UIStackView, stackHeight: NSLayoutConstraint, items: [String], defaultButtonTitle: String){
        
        var counter = 0;
        var loopCount = 0;
        var horizontalStackView = newHorizontalStackView(stackView: stackView)

        setStackViewHeight(stackView: stackView, stackHeight: stackHeight, count: items.count)
        
        for item in items {
            counter += 1
            loopCount += 1
            
            let button = UIButton()
            button.setTitle(item, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            
            horizontalStackView.addArrangedSubview(button)
            
            if counter == 2 {
                counter = 0
                stackView.addArrangedSubview(horizontalStackView)
                if loopCount != items.count {
                    horizontalStackView = newHorizontalStackView(stackView: stackView)
                }
            }
        }
        // Add the default Add Tracker button
        if items.count % 2 == 0 {
            horizontalStackView = newHorizontalStackView(stackView: stackView)
        }
        
        let button = UIButton()
        button.setTitle(defaultButtonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        button.addTarget(self, action: #selector(StackDetailsViewController.defaultButtonClicked(_:)), for: .touchUpInside)
        
        horizontalStackView.addArrangedSubview(button)
        
        if items.count % 2 == 0 {
            let clearView = UIView()
            horizontalStackView.addArrangedSubview(clearView)
        }
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    @objc func defaultButtonClicked(_ sender: UIButton) {
        if sender.titleLabel?.text == "+ Add Tracker"{
            performSegue(withIdentifier: "addTracker", sender: self)
        } else {
            performSegue(withIdentifier: "addChecklist", sender: self)
        }
    }
    
    func setStackViewHeight(stackView: UIStackView, stackHeight: NSLayoutConstraint, count: Int){
        let rows: Double = ceil(Double(count + 1) / 2.0)
        let height = (rows * 60) + ((rows - 1) * 15)
        
        stackHeight.constant = CGFloat(height)
        stackView.layoutIfNeeded()
    }
    
    func newHorizontalStackView(stackView: UIStackView) -> UIStackView {
        let newStackView = UIStackView()
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        newStackView.axis = .horizontal
        newStackView.spacing = 25
        newStackView.distribution = .fillEqually
        newStackView.alignment = .fill
        
        newStackView.heightAnchor.constraint(equalToConstant: 60)
        newStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
        newStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)
        return newStackView
    }
}
