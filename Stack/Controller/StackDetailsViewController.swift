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
    
    @IBOutlet weak var trackersStackView: UIStackView!
    @IBOutlet weak var checklistStackView: UIStackView!
    @IBOutlet weak var trackersHeightConstraint: NSLayoutConstraint!
    
    let trackers = ["Gloves","Goggles","Gloves","Goggles"]//,"Boots","Helmet","Snowboard"]
    let checklist = ["Pass", "Glasses"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI(){
        var count = 0;
        var horizontalStackView = newHorizontalStackView()
        let rows: Double = ceil(Double(trackers.count + 1) / 2.0)
        let height = (rows * 60) + ((rows - 1) * 15)
        trackersStackView.heightAnchor.constraint(equalToConstant: CGFloat(rows))
        trackersHeightConstraint.constant = CGFloat(height)
        trackersStackView.layoutIfNeeded()
        //updateViewConstraints()
        
        for tracker in trackers {
            count += 1

            let button = UIButton()
            button.setTitle(tracker, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            
            horizontalStackView.addArrangedSubview(button)
            
            if count == 2 {
                count = 0
                trackersStackView.addArrangedSubview(horizontalStackView)
                horizontalStackView = newHorizontalStackView()
            }
        }
        // If odd number that add the Add Tile to the same horizontal view
        if trackers.count % 2 == 0 {
            horizontalStackView = newHorizontalStackView()
        }
        let trackerView = UIView()
        trackerView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        horizontalStackView.addArrangedSubview(trackerView)
        let clearView = UIView()
        //trackerView.backgroundColor = UIColor.clear
        horizontalStackView.addArrangedSubview(clearView)
        trackersStackView.addArrangedSubview(horizontalStackView)
        
        // Add the default Add Tracker button
        
    }
    
    func newHorizontalStackView() -> UIStackView {
        let newStackView = UIStackView()
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        newStackView.axis = .horizontal
        newStackView.spacing = 25
        newStackView.distribution = .fillEqually
        newStackView.alignment = .fill
        
        newStackView.heightAnchor.constraint(equalToConstant: 60)
        newStackView.leadingAnchor.constraint(equalTo: trackersStackView.leadingAnchor, constant: 0)
        newStackView.trailingAnchor.constraint(equalTo: trackersStackView.trailingAnchor, constant: 0)
        //newStackView.topAnchor.constraint(equalTo: trackersStackView.topAnchor, constant: 0)
        return newStackView
    }
}
