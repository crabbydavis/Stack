//
//  StacksViewController.swift
//  Stack
//
//  Created by Davis Crabb on 5/20/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit

class StacksViewController: UIViewController {
    
    @IBOutlet weak var currentStackView: UIStackView!
    @IBOutlet weak var otherStackView: UIStackView!
    @IBOutlet weak var currentStackViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var otherStackViewHeight: NSLayoutConstraint!
    
    var currentStacks = [String]() //["Snowboarding", "Camping"]
    var otherStacks = [String]() //["General"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (identifier, stack) in StacksManager.stacks {
            if stack.isCurrent == true {
                currentStacks.append(identifier)
            } else {
                otherStacks.append(identifier)
            }
        }
        initUI()
    }
    
    func initUI(){
        addItemsToStackView(stackView: currentStackView, stackHeight: currentStackViewHeight, items: currentStacks)
        addItemsToStackView(stackView: otherStackView, stackHeight: otherStackViewHeight, items: otherStacks, defaultButtonTitle: "+ Add Stack")
    }
    
    func addItemsToStackView(stackView: UIStackView, stackHeight: NSLayoutConstraint, items: [String], defaultButtonTitle: String? = nil){
        
        var counter = 0;
        var loopCount = 0;
        var horizontalStackView = newHorizontalStackView(stackView: stackView)
        
        if defaultButtonTitle != nil {
            setStackViewHeight(stackView: stackView, stackHeight: stackHeight, count: items.count, extraButton: true)
        } else {
            setStackViewHeight(stackView: stackView, stackHeight: stackHeight, count: items.count, extraButton: false)
        }
        
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
        if defaultButtonTitle != nil {
            if items.count % 2 == 0 {
                horizontalStackView = newHorizontalStackView(stackView: stackView)
            }
            
            if let title = defaultButtonTitle {
                let button = UIButton()
                button.setTitle(title, for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                button.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                
                horizontalStackView.addArrangedSubview(button)
            }
            if items.count % 2 == 0 {
                let clearView = UIView()
                horizontalStackView.addArrangedSubview(clearView)
            }
        stackView.addArrangedSubview(horizontalStackView)
        }
    }
    
    func setStackViewHeight(stackView: UIStackView, stackHeight: NSLayoutConstraint, count: Int, extraButton: Bool){
        var rows: Double = 0.0
        if extraButton == true {
            rows = ceil(Double(count + 1) / 2.0)
        } else {
            rows = ceil(Double(count) / 2.0)
        }
        let height = (rows * 143) + ((rows - 1) * 15)
        
        stackHeight.constant = CGFloat(height)
        stackView.layoutIfNeeded()
    }
    
    func newHorizontalStackView(stackView: UIStackView) -> UIStackView {
        let newStackView = UIStackView()
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        newStackView.axis = .horizontal
        newStackView.spacing = 21
        newStackView.distribution = .fillEqually
        newStackView.alignment = .fill
        
        newStackView.heightAnchor.constraint(equalToConstant: 143)
        newStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
        newStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)
        return newStackView
    }
}
