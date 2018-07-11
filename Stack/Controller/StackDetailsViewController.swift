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
    
    @IBAction func donePushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBOutlet weak var trackersStackView: UIStackView!
    @IBOutlet weak var checklistStackView: UIStackView!
    @IBOutlet weak var overlayTrackersStackView: UIStackView!
    @IBOutlet weak var overlayChecklistStackView: UIStackView!
    
    @IBOutlet weak var trackersHeight: NSLayoutConstraint!
    @IBOutlet weak var checklistHeight: NSLayoutConstraint!
    @IBOutlet weak var overlayTrackersHeight: NSLayoutConstraint!
    @IBOutlet weak var overlayChecklistHeight: NSLayoutConstraint!
    
    
    var trackers = [String:UIImage?]()
    var checklists = [String:UIImage?]()
    var stackName: String = ""
    var stack: Stack?
    var tappedItemName: String = ""
    
    @IBOutlet weak var viewTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Initialize UI here because view may not get destroyed before viewing again
    override func viewWillAppear(_ animated: Bool) {
       
        // First clear whatever is currently showing
        for subview in trackersStackView.arrangedSubviews {
            trackersStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in checklistStackView.arrangedSubviews {
            checklistStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in overlayTrackersStackView.arrangedSubviews {
            overlayTrackersStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in overlayChecklistStackView.arrangedSubviews {
            overlayChecklistStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // Clear and then re-create the current and other stacks
        trackers.removeAll()
        checklists.removeAll()
        if let stack = StacksManager.stacks[stackName] {
            for (identifier, tracker) in  stack.trackers {
                trackers.updateValue(tracker.image, forKey: identifier)
            }
            for (identifier, checklist) in  stack.checklist {
                checklists.updateValue(checklist.image, forKey: identifier)
            }
        }
        initUI()
    }
    
    func initUI(){
        // Set the title of the view
        viewTitle.text = stackName
        
        overlayTrackersStackView.layer.zPosition = 100
        overlayChecklistStackView.layer.zPosition = 100
        
        // Set up the stack views
        addItemsToStackView(stackView: trackersStackView, stackHeight: trackersHeight, overlayStackView: overlayTrackersStackView, overlayStackHeight: overlayTrackersHeight, items: trackers, defaultButtonTitle: "+ Add Tracker")
        addItemsToStackView(stackView: checklistStackView, stackHeight: checklistHeight, overlayStackView: overlayChecklistStackView, overlayStackHeight: overlayChecklistHeight, items: checklists, defaultButtonTitle: "+ Add Checklist")
    }
    
    func addItemsToStackView(stackView: UIStackView, stackHeight: NSLayoutConstraint, overlayStackView: UIStackView, overlayStackHeight: NSLayoutConstraint, items: [String:UIImage?], defaultButtonTitle: String){
        
        var counter = 0;
        var loopCount = 0;
        var horizontalStackView = newHorizontalStackView(stackView: stackView)
        var overlayHorizontalStackView = newHorizontalStackView(stackView: overlayStackView)
        
        setStackViewHeight(stackView: stackView, stackHeight: stackHeight, overlayStackView: overlayStackView, overlayStackHeight: overlayStackHeight, count: items.count)
        
        for (itemName, itemImage) in items {
            counter += 1
            loopCount += 1
            
            let button = UIButton()
            button.setTitle(itemName, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            
            let imageButton = UIButton()
            if let image = itemImage {
                imageButton.setImage(image, for: .normal)
                imageButton.contentMode = .scaleAspectFit
            }
            imageButton.setTitle(itemName, for: .normal)
            imageButton.setTitleColor(UIColor.clear, for: .normal)
            imageButton.addTarget(self, action: #selector(StackDetailsViewController.itemClicked(_:)), for: .touchUpInside)
            horizontalStackView.addArrangedSubview(imageButton)

            overlayHorizontalStackView.addArrangedSubview(button)
            
            if counter == 2 {
                counter = 0
                stackView.addArrangedSubview(horizontalStackView)
                overlayStackView.addArrangedSubview(overlayHorizontalStackView)
                if loopCount != items.count {
                    horizontalStackView = newHorizontalStackView(stackView: stackView)
                    overlayHorizontalStackView = newHorizontalStackView(stackView: overlayStackView)
                }
            }
        }
        // Add the default Add Tracker button
        if items.count % 2 == 0 {
            horizontalStackView = newHorizontalStackView(stackView: stackView)
            overlayHorizontalStackView = newHorizontalStackView(stackView: overlayStackView)
        }
        
        let button = UIButton()
        button.setTitle(defaultButtonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        button.addTarget(self, action: #selector(StackDetailsViewController.defaultButtonClicked(_:)), for: .touchUpInside)
        
        horizontalStackView.addArrangedSubview(button)
        overlayHorizontalStackView.addArrangedSubview(UIView())
        
        if items.count % 2 == 0 {
            horizontalStackView.addArrangedSubview(UIView())
            overlayHorizontalStackView.addArrangedSubview(UIView())
        }
        
        stackView.addArrangedSubview(horizontalStackView)
        overlayStackView.addArrangedSubview(overlayHorizontalStackView)
    }
    
    @objc func itemClicked(_ sender: UIButton) {
        if let name = sender.titleLabel?.text {
            tappedItemName = name
        }
        performSegue(withIdentifier: "showItemDetails", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetails" {
            let addTrackerVC = segue.destination as! AddTrackerViewController
            addTrackerVC.itemName = tappedItemName
        }
    }
    
    @objc func defaultButtonClicked(_ sender: UIButton) {
        if sender.titleLabel?.text == "+ Add Tracker"{
            performSegue(withIdentifier: "addTracker", sender: self)
        } else {
            performSegue(withIdentifier: "addChecklist", sender: self)
        }
    }
    
    func setStackViewHeight(stackView: UIStackView, stackHeight: NSLayoutConstraint, overlayStackView: UIStackView, overlayStackHeight: NSLayoutConstraint, count: Int){
        let rows: Double = ceil(Double(count + 1) / 2.0)
        let height = (rows * 60) + ((rows - 1) * 15)
        
        stackHeight.constant = CGFloat(height)
        overlayStackHeight.constant = CGFloat(height)
        
        stackView.layoutIfNeeded()
        overlayStackView.layoutIfNeeded()
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
