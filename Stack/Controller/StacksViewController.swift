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
    
    // Stack Views
    @IBOutlet weak var currentStackView: UIStackView!
    @IBOutlet weak var otherStackView: UIStackView!
    @IBOutlet weak var overlayOtherStackView: UIStackView!
    @IBOutlet weak var overlayCurrentStackView: UIStackView!
    
    // Stack View Height Constraints
    @IBOutlet weak var currentStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var otherStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var overlayOtherStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var overlayCurrentStackViewHeight: NSLayoutConstraint!
    
    var currentStacks = [Stack]()//[String]() //["Snowboarding", "Camping"]
    var otherStacks = [Stack]()//[String]() //["General"]
    
    var clickedStackTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Initialize UI here because view may not get destroyed before viewing again
    override func viewWillAppear(_ animated: Bool) {
        // First clear whatever is currently showing
        for subview in currentStackView.arrangedSubviews {
            currentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in otherStackView.arrangedSubviews {
            otherStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in overlayCurrentStackView.arrangedSubviews {
            overlayCurrentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in overlayOtherStackView.arrangedSubviews {
            overlayOtherStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // Clear and then re-create the current and other stacks
        currentStacks.removeAll()
        otherStacks.removeAll()
        for (_, stack) in StacksManager.stacks {
            if stack.isCurrent == true {
                currentStacks.append(stack)
            } else {
                otherStacks.append(stack)
            }
        }
        initUI()
    }
    
    func initUI(){
        overlayOtherStackView.layer.zPosition = 100
        overlayCurrentStackView.layer.zPosition = 100
        if currentStacks.count > 0 {
            addItemsToStackView(stackView: currentStackView, stackHeight: currentStackViewHeight, overlayStackView: overlayCurrentStackView, overlayStackHeight: overlayCurrentStackViewHeight, stacks: currentStacks)
        } else {
            addNoStacksRectangle()
        }
        addItemsToStackView(stackView: otherStackView, stackHeight: otherStackViewHeight, overlayStackView: overlayOtherStackView, overlayStackHeight: overlayOtherStackViewHeight, stacks: otherStacks, defaultButtonTitle: "+ Add Stack")
    }
    
    func addItemsToStackView(stackView: UIStackView, stackHeight: NSLayoutConstraint, overlayStackView: UIStackView, overlayStackHeight: NSLayoutConstraint, stacks: [Stack], defaultButtonTitle: String? = nil){
        
        var counter = 0;
        var loopCount = 0;
        
        if defaultButtonTitle != nil {
            setStackViewHeight(stackView: stackView, stackHeight: stackHeight, overlayStackView: overlayStackView, overlayStackHeight: overlayStackHeight, count: stacks.count, extraButton: true)
        } else {
            setStackViewHeight(stackView: stackView, stackHeight: stackHeight, overlayStackView: overlayStackView, overlayStackHeight: overlayStackHeight, count: stacks.count, extraButton: false)
        }
        
        var horizontalStackView = newHorizontalStackView(stackView: stackView)
        var overlayhorizontalStackView = newHorizontalStackView(stackView: overlayStackView)
        
        for stack in stacks {
            counter += 1
            loopCount += 1
            
            // Add a button for the stack
            let button = UIButton()
            button.setTitle(stack.name, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            
            let imageButton = UIButton()
            if let image = stack.image {
                imageButton.setImage(image, for: .normal)
            }
            imageButton.contentMode = .scaleAspectFit
            imageButton.setTitle(stack.name, for: .normal)
            imageButton.setTitleColor(UIColor.clear, for: .normal)
            imageButton.addTarget(self, action: #selector(StacksViewController.stackClicked(_:)), for: .touchUpInside)
            horizontalStackView.addArrangedSubview(imageButton)
            
            overlayhorizontalStackView.addArrangedSubview(button)
            
            // If there the row is full then add another horizontal stack view
            if counter == 2 {
                counter = 0
                stackView.addArrangedSubview(horizontalStackView)
                overlayStackView.addArrangedSubview(overlayhorizontalStackView)
                if loopCount != stacks.count {
                    horizontalStackView = newHorizontalStackView(stackView: stackView)
                    overlayhorizontalStackView = newHorizontalStackView(stackView: overlayStackView)
                }
            }
        }
        // Add the default Add Tracker button
        if defaultButtonTitle != nil {
            if stacks.count % 2 == 0 {
                horizontalStackView = newHorizontalStackView(stackView: stackView)
                overlayhorizontalStackView = newHorizontalStackView(stackView: overlayStackView)
            }
            
            if let title = defaultButtonTitle {
                let button = UIButton()
                button.setTitle(title, for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                button.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                button.addTarget(self, action: #selector(StacksViewController.addStackClicked(_:)), for: .touchUpInside)
                horizontalStackView.addArrangedSubview(button)
                
                let clearView = UIView()
                overlayhorizontalStackView.addArrangedSubview(clearView)
            }
            if stacks.count % 2 == 0 {
                let clearView1 = UIView()
                let clearView2 = UIView()
                horizontalStackView.addArrangedSubview(clearView1)
                overlayhorizontalStackView.addArrangedSubview(clearView2)
            }
            stackView.addArrangedSubview(horizontalStackView)
            overlayStackView.addArrangedSubview(overlayhorizontalStackView)
        }
    }
    
    @objc func stackClicked(_ sender: UIButton) {
        print("Stack Clicked")
        if let title = sender.titleLabel?.text{
            clickedStackTitle = title
        }
        performSegue(withIdentifier: "goToStackDetails", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToStackDetails" {
            let stackDetailsVC = segue.destination as! StackDetailsViewController
            stackDetailsVC.stackName = clickedStackTitle
        }
    }
    
    @objc func addStackClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "addStack", sender: self)
    }
    
    func setStackViewHeight(stackView: UIStackView, stackHeight: NSLayoutConstraint, overlayStackView: UIStackView, overlayStackHeight: NSLayoutConstraint, count: Int, extraButton: Bool){
        var rows: Double = 0.0
        if extraButton == true {
            rows = ceil(Double(count + 1) / 2.0)
        } else {
            rows = ceil(Double(count) / 2.0)
        }
        let height = (rows * 143) + ((rows - 1) * 15)
        
        stackHeight.constant = CGFloat(height)
        overlayStackHeight.constant = CGFloat(height)
        
        stackView.layoutIfNeeded()
        overlayStackView.layoutIfNeeded()
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
    
    func addNoStacksRectangle(){
        //stackView: currentStackView, stackHeight: currentStackViewHeight
        currentStackViewHeight.constant = CGFloat(71)
        
        let button = UIButton()
        button.setTitle("No Nearby Stacks", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        currentStackView.addArrangedSubview(button)
    }
}
