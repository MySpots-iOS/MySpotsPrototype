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
    
    // A default location to use when location permission is not granted.
    fileprivate let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    fileprivate var placeInformationView: PlaceInformation? = nil
    fileprivate var generalInformation: UIView? = nil
    fileprivate var generalInfoBottomConstraints: [NSLayoutConstraint] = []
    
    //TODO
    // marker variable that stored from database
    var markers: [GMSMarker] = []
    
    // another marker variable is temp
    fileprivate var tempMarker: GMSMarker? = nil
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("Executed: Willmove")
        animateHideView()
        //mapView.clear()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Executed: didtapmarker")
        setGeneralInformation(marker.snippet!)
        return true
    }
    
    func mapView(_ mapView:GMSMapView, idleAt cameraPosition:GMSCameraPosition) {
        reverseGeocodeCoordinate(cameraPosition.target)
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // Store GMSGeocoder as an instance variable.
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            guard error == nil else {
                return
            }
            
//            if let result = response?.firstResult() {
//                print(result)
//            }
        }
    }
    
    /**
     Tap event which is not a place from Google Place
     
     - parameters:
        - mapView: Map View
        - coordinate: Tapped loacation coordinate(2D)
     
    */
    func mapView(_ mapView:GMSMapView, didTapAt coordinate:CLLocationCoordinate2D) {
        print("Executed: TapAt CL")
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        tempMarker?.map = nil
        animateHideView()
    }
    
    /**
     Tap event on Google Map
     
     - parameters:
        - mapView: Map View
        - placeID: Place identifier that it is stored Google Places
        - name: Place name
        - location: Place location coordinate(2D)
     
     */
    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String, name:String, location:CLLocationCoordinate2D) {
        print("Executed: POI")
        print("You tapped at \(location.latitude), \(location.longitude)")
        setGeneralInformation(placeID)
        tempMarker = makeMarker(position: location, placeID: placeID, color: .black)
    }
    
    /**
     Set data to the information view
     
     - parameters:
        - placeID: Place identifier
     
    */
    func setGeneralInformation(_ placeID: String) {
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            self.placeInformationView?.setSelectedPlaceName(place.name)
            self.placeInformationView?.setSelectedAddress(place.formattedAddress!)
            
            print("Place placeID \(place.placeID)")
            print("Place attributions \(String(describing: place.attributions))")
            print("Place category \(place.types)")
            print("Place rating \(place.rating)")
        })
        animateShowView()
    }
    
    
    /**
     Make marker on Google Map
     
     - parameters:
        - position: Location Coordinate(2D)
        - placeID: Place ID
        - color: Marker Color
     
     */
    func makeMarker(position: CLLocationCoordinate2D, placeID: String, color: UIColor) -> GMSMarker {
        let marker = GMSMarker(position: position)
        marker.snippet = placeID
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
        return marker
    }
    
}

extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationInit()
        mapInit()
        
        // TODO load locations function
        
        makeInformationView()
        
        // TEST DATA
        markers.append(makeMarker(position: CLLocationCoordinate2D.init(latitude: 37.7859022974905, longitude: -122.410837411881), placeID: "ChIJAAAAAAAAAAARembxZUVcNEk", color: .black))
        markers.append(makeMarker(position: CLLocationCoordinate2D.init(latitude: 37.7906928118546, longitude: -122.405601739883), placeID: "ChIJAAAAAAAAAAARknLi-eNpMH8", color: .black))
        markers.append(makeMarker(position: CLLocationCoordinate2D.init(latitude: 37.7887342497061, longitude: -122.407184243202), placeID: "ChIJAAAAAAAAAAARdxDXMalu6mY", color: .black))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Location initial function
     
     - Attention: test
     - Bug: test
     - Date: date
     - Experiment: test
     - Important: test
     - Invariant: test
     - Note: test
     - Precondition: test
     - Postcondition: test
     - Remark: test
     - Requires: test
     - Since: @0.0.1
     - Version: 1.0
     - Warning: test
     
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detailView(_:)))
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        
        generalInformation.addGestureRecognizer(tapGesture)
        self.view.addSubview(generalInformation)
        
        generalInformation.translatesAutoresizingMaskIntoConstraints = false
        generalInformation.heightAnchor.constraint(equalToConstant: 100).isActive = true
        generalInformation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        generalInformation.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        self.generalInfoBottomConstraints.append(generalInformation.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 100))
        self.generalInfoBottomConstraints.append(generalInformation.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0))
        // Set default
        self.generalInfoBottomConstraints[0].isActive = true
    }
    
    func detailView(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.test = "aaa"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     Information View hide animation
     
     */
    func animateHideView() {
        self.generalInfoBottomConstraints[1].isActive = false
        self.generalInfoBottomConstraints[0].isActive = true
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    /**
     Information View show animation
     
     */
    func animateShowView() {
        self.generalInfoBottomConstraints[0].isActive = false
        self.generalInfoBottomConstraints[1].isActive = true
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
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
