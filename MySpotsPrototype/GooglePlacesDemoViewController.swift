//
//  GooglePlacesDemoViewController.swift
//  MySpotsPrototype
//
//  Created by Michinobu Nishimoto on 2017-06-15.
//  Copyright © 2017 Michinobu Nishimoto. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class GooglePlacesDemoViewController: UIViewController, GMSPlacePickerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func pickPlace(_ sender: UIButton) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(String(describing: place.formattedAddress))")
        print("Place attributions \(String(describing: place.attributions))")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }

}
