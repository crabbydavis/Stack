//
//  HomeViewController.swift
//  Stack
//
//  Created by Davis Crabb on 5/20/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Request always authorization on the home page
        locationManager.requestAlwaysAuthorization()
        //initUI()
    }
    /*
    func initUI() {
        // Add the Notifications view
        let notificationView = UIView()
        notificationView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        notificationView.widthAnchor.constraint(equalToConstant: 307)
        notificationView.heightAnchor.constraint(equalToConstant: 212)
        stackView.addArrangedSubview(notificationView)
        
        let notificationLabel = UILabel()
        notificationLabel.text = "Notifications"
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 13)
        notificationLabel.center.x = notificationView.center.x
        notificationView.addSubview(notificationLabel)
        
        // Add the Add Stack and Add Tracker buttons
        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 21
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .fill
        
        horizontalStackView.heightAnchor.constraint(equalToConstant: 143)
        horizontalStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
        horizontalStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)
        
        let addStackButton = UIButton()
        addStackButton.setTitle("+ Add Stack", for: .normal)
        addStackButton.setTitleColor(UIColor.white, for: .normal)
        addStackButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        addStackButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        let addTrackerButton = UIButton()
        addStackButton.setTitle("+ Add Tracker", for: .normal)
        addStackButton.setTitleColor(UIColor.white, for: .normal)
        addStackButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        addStackButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        horizontalStackView.addArrangedSubview(addStackButton)
        horizontalStackView.addArrangedSubview(addTrackerButton)
        
        // Add the geofence view
        let addGeofenceButton = UIButton()
        addGeofenceButton.setTitle("Set Geofence", for: .normal)
        addGeofenceButton.setTitleColor(UIColor.white, for: .normal)
        addGeofenceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        addGeofenceButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        addGeofenceButton.translatesAutoresizingMaskIntoConstraints = false
        addGeofenceButton.heightAnchor.constraint(equalToConstant: 66)
        
        // Add views to the Stack View
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(addGeofenceButton)
    }
     */
}
