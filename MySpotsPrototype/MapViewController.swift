//
//  ViewController.swift
//  MySpotsPrototype
//
//  Created by Michinobu Nishimoto on 2017-06-15.
//  Copyright © 2017 Michinobu Nishimoto. All rights reserved.
//

import UIKit
import GoogleMaps
//import GooglePlaces
import GooglePlacePicker

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // Declare GMSMarker instance at the class level.
    let infoMarker = GMSMarker()
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationInit()
        mapInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationInit() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
        
        placesClient = GMSPlacesClient.shared()
    }
    
    func mapInit() {
        // Create a map
        // if user current location can not get, it will be set default position
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
    }
    
    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String,
                 name:String, location:CLLocationCoordinate2D) {
        
        // When user tapped a place, picker will be shown up
        
//        infoMarker.snippet = placeID
//        infoMarker.position = location
//        infoMarker.title = name
//        infoMarker.opacity = 0;
//        infoMarker.infoWindowAnchor.y = 1
//        infoMarker.map = mapView
        placeInfo(placeID: placeID)
        
        
        // Marker Test
        let marker = GMSMarker(position: location)
        // Marker Color Changes
        marker.icon = GMSMarker.markerImage(with: .black)
        // no need it
        marker.title = "Hello World"
        // Add
        marker.map = mapView
        
        makeInformationView()
        
        mapView.selectedMarker = infoMarker
    }
    
    func makeInformationView() {
        //let generalInformation: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
        let generalInformation: UIView = PlaceInformation(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        self.view.addSubview(generalInformation)
        
        generalInformation.backgroundColor = UIColor.white
        
        generalInformation.translatesAutoresizingMaskIntoConstraints = false
        generalInformation.heightAnchor.constraint(equalToConstant: 100).isActive = true
        generalInformation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        generalInformation.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        generalInformation.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
    }
    
    func placeInfo(placeID: String) {
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(place.name)")
            print("Place address \(String(describing: place.formattedAddress))")
            print("Place placeID \(place.placeID)")
            print("Place attributions \(String(describing: place.attributions))")
            print("Place category \(place.types)")
            print("Place rating \(place.rating)")
        })
    }
    
//    @IBAction func pickPlace(_ sender: UIButton) {
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        placePicker.delegate = self
//        present(placePicker, animated: true, completion: nil)
//    }
    
//    // To receive the results from the place picker 'self' will need to conform to
//    // GMSPlacePickerViewControllerDelegate and implement this code.
//    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//        // Dismiss the place picker, as it cannot dismiss itself.
//        viewController.dismiss(animated: true, completion: nil)
//        
//        print("Place name \(place.name)")
//        print("Place address \(String(describing: place.formattedAddress))")
//        print("Place attributions \(String(describing: place.attributions))")
//        print("Place Type \(String(describing: place.types))")
//    }
//    
//    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
//        // Dismiss the place picker, as it cannot dismiss itself.
//        viewController.dismiss(animated: true, completion: nil)
//        
//        print("No place selected")
//    }


}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        //listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
