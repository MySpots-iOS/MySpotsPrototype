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
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var mapView: GMSMapView!
    fileprivate var placesClient: GMSPlacesClient!
    fileprivate var zoomLevel: Float = 15.0
    
    // Declare GMSMarker instance at the class level.
    fileprivate let infoMarker = GMSMarker()
    
    // A default location to use when location permission is not granted.
    fileprivate let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    fileprivate var placeInformationView: PlaceInformation? = nil
    fileprivate var generalInformation: UIView? = nil
    
    
    /**
     Tap event on Google Map
     
     - parameters:
        - mapView: Map View
        - placeID: Place identifier that it is stored Google Places
        - name: Place name
        - location: Place location coordinate(2D)
     
     */
    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String, name:String, location:CLLocationCoordinate2D) {
        // When user tapped a place, picker will be shown up
        
//        infoMarker.snippet = placeID
//        infoMarker.position = location
//        infoMarker.title = name
//        infoMarker.opacity = 0;
//        infoMarker.infoWindowAnchor.y = 1
//        infoMarker.map = mapView
//        placeInfo(placeID: placeID)
        
        
//        makeInformationView()
        
        makeMarker(position: location, color: .black)
        
        generalInformation?.isHidden = false
        
        //mapView.selectedMarker = infoMarker
    }
    
    
    /**
     Make marker on Google Map
     
     - parameters:
        - position: Location Coordinate(2D)
        - color: Marker Color
     
     */
    func makeMarker(position: CLLocationCoordinate2D, color: UIColor) {
        let marker = GMSMarker(position: position)
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
    }
    
    
    
//    func placeInfo(placeID: String) {
//        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
//            if let error = error {
//                print("lookup place id query error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let place = place else {
//                print("No place details for \(placeID)")
//                return
//            }
//            
//            print("Place name \(place.name)")
//            print("Place address \(String(describing: place.formattedAddress))")
//            print("Place placeID \(place.placeID)")
//            print("Place attributions \(String(describing: place.attributions))")
//            print("Place category \(place.types)")
//            print("Place rating \(place.rating)")
//        })
//    }
}

extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationInit()
        mapInit()
        
        // TODO load locations function
        
        makeInformationView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Location initial function
     
     
     */
    func locationInit() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
        
        placesClient = GMSPlacesClient.shared()
    }
    
    
    /**
     Google Map initial function
     
     - Requires:
        Google API Key
     
     - SeeAlso:
        AppDelegate file
    */
    func mapInit() {
        // if user current location can not get, it will be set default position
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
    }
    
    /**
     Information View, if user tapped a place, the view will be shown the place information
     
     - Note:
        Using Xib file for layout. See also: PlaceInformation.swift / xib
     
    */
    func makeInformationView() {
        placeInformationView = PlaceInformation(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        generalInformation = placeInformationView!
        
        guard let generalInformation = generalInformation else {
            print("nil error")
            return
        }
        
        self.view.addSubview(generalInformation)
        
        generalInformation.translatesAutoresizingMaskIntoConstraints = false
        generalInformation.heightAnchor.constraint(equalToConstant: 100).isActive = true
        generalInformation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        generalInformation.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        generalInformation.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        generalInformation.isHidden = true
    }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
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
        case .authorizedAlways:
            fallthrough
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
