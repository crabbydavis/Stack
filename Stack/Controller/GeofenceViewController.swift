//
//  GeofenceViewController.swift
//  Location
//
//  Created by Davis Crabb on 5/12/18.
//  Copyright © 2018 Davis Crabb. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Toaster

class GeofenceSetupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBAction func addressSubmit(_ sender: UITextField) {
        
        // Do something with the address
    }
    @IBAction func useLocationButton(_ sender: UIButton) {
    }
    
    @IBAction func cancelGeofence(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        addressTextField.delegate = self
    }
    
    func initUI(){
         addressTextField.layer.borderWidth = 1
         addressTextField.layer.borderColor = UIColor.white.cgColor
         addressTextField.attributedPlaceholder = NSAttributedString(string: "Enter Address",
         attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
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
        addressTextField.endEditing(true)
        return true
    }
}

class GeofenceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBAction func sliderChange(_ sender: UISlider) {
        mapView.remove(geofenceCircle!)
        geofenceCircle = MKCircle(center: geofenceCircle!.coordinate, radius: Double(sender.value))
        mapView.add(geofenceCircle!)
    }
    @IBOutlet weak var nameTextField: UITextField!
    @IBAction func nameSubmit(_ sender: UITextField) {
        // Set this to the geofence title
    }
    
    @IBOutlet weak var textFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewTopConstraint: NSLayoutConstraint!
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBAction func saveGeofence(_ sender: UIButton) {
        //StacksManager.geofences.updateValue(<#T##value: Geofence##Geofence#>, forKey: <#T##String#>)
        if let visualGeofence = geofenceCircle {
            let region = CLCircularRegion(center: visualGeofence.coordinate, radius: visualGeofence.radius, identifier: nameTextField.text!)
            locationManager.startMonitoring(for: region)
            let geofence = Geofence(insideGeofence: true, circularRegion: region)
            print("nameTextField: \(nameTextField.text!)")
            StacksManager.geofences.updateValue(geofence, forKey: nameTextField.text!)
            ToastView.appearance().bottomOffsetPortrait = CGFloat(UIScreen.main.bounds.height * 0.5)
            ToastView.appearance().font = UIFont.systemFont(ofSize: 20)//UIFont(descriptor: "Roboto", size: 20)
            ToastView.appearance().backgroundColor = UIColor(red:0.12, green:0.76, blue:0.65, alpha:1.0)//1FC3A6
            ToastView.appearance().textColor = UIColor.white
            let toast = Toast(text: "Geofence Saved", duration: Delay.short)
            toast.show()
            
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    let locationManager = CLLocationManager()
    let homeAnnotation = MKPointAnnotation()
    var geofenceCircle: MKCircle? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        initUI()
        initMapView()
        initLocationManager()
        loadGeofence()
    }
    
    func initUI(){
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.white.cgColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name Geofence",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    }
    
    func initLocationManager(){
        locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization() // Requesting to always have access to location
        //locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.distanceFilter = kCLLocationAccuracyKilometer
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func initMapView(){
        mapView.delegate = self
        mapView.userTrackingMode = .none
        
        // Track when the user has pressed on the map to move the marker
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(GeofenceViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        homeAnnotation.coordinate = touchMapCoordinate
        if let circle = geofenceCircle {
            mapView.remove(circle)
            geofenceCircle = MKCircle(center: touchMapCoordinate, radius: geofenceCircle!.radius)
            mapView.add(geofenceCircle!)
        }
    }
    
    func loadGeofence() {
        let regionRadius: Double = Double(slider.value)
        let title = "HomeGeofence"
        locationManager.requestLocation()
        
        if let coordinate = locationManager.location?.coordinate {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                         longitude: coordinate.longitude), radius: regionRadius, identifier: title)
            
            homeAnnotation.coordinate = coordinate; // initialize the marker at the current location
            mapView.addAnnotation(homeAnnotation)

            // Setup the geofence on the map
            geofenceCircle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.add(geofenceCircle!)
            mapView.mapType = .satellite
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinate, 50, 50), animated: true)
        }
        //locationManager.startMonitoring(for: region)
    }
    
    //////////////////////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
        return true
    }
    
    //////////////////////////////////////////////////////////
    // MARK: - MapView Delegate Methods
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor(red: 0, green: 198, blue: 167, alpha: 0.7)
        circleRenderer.lineWidth = 2.0
        return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let userLocation = mapView.view(for: mapView.userLocation) {
            userLocation.isHidden = true
        }
    }
    
    /*
     // Use the following to try and make the marker draggable
     func  mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
     view.isDraggable = true
     mapView.isScrollEnabled = false
     if let circle = geofenceCircle {
     mapView.remove(circle)
     }
     }
     
     func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
     if let annotation = view.annotation {
     view.isDraggable = false
     mapView.isScrollEnabled = true
     geofenceCircle = MKCircle(center: annotation.coordinate, radius: 5)
     mapView.add(geofenceCircle!)
     }
     }
     
     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
     switch newState {
     case .starting:
     view.dragState = .dragging
     case .ending, .canceling:
     view.dragState = .none
     default: break
     }
     }*/
    
    //////////////////////////////////////////////////////////
    // MARK: - Location Manager Delegate Methods
    // This locations array usually only has 1 location in it, but sometimes it'll have 2
    // The last location in the array will be the most accurate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            print("\(index): \(currentLocation)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Failed \(error)")
    }
}


