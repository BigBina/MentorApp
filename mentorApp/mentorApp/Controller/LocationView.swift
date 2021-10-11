//
//  LocationView.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/4/21.
//

import UIKit
import CoreLocation

class LocationView: UIViewController {
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var pickerView = UIPickerView()
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Keyboard Method
        hideKeyboardWhenTappedAround()
        
        //Picker View Initializers
        pickerView.delegate = self
        pickerView.dataSource = self
        stateField.inputView = pickerView
        stateField.textAlignment = .center
        stateField.placeholder = "Select State"
        stateField.delegate = self
        cityField.delegate = self
        
        
        //Location Initializers
        locationManager.delegate = self
     
        
    }

    public func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View

        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")

        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                cityField.text = placemark.locality
                stateField.text = placemark.administrativeArea
            } else {
                cityField.text = "No Matching Addresses Found"
            }
        }
    }
    @IBAction func nextButton(_ sender: Any) {
        if cityField.text != "" && stateField.text != ""{
            performSegue(withIdentifier: "LocationToCategories", sender: self)
        } else{
            errorLabel.text = "Please fill out required fields: City and State"
        }
    }
    
}

//MARK: - Picker View for the State Selection
extension LocationView: UIPickerViewDelegate, UIPickerViewDataSource{

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return States.stateTuple.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return States.stateTuple[row].full
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateField.text = States.stateTuple[row].abbr
        stateField.resignFirstResponder()
    }

}

extension LocationView: CLLocationManagerDelegate, UITextFieldDelegate{
    @IBAction func liveLocationButton(_ sender: Any) {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            let locationB = CLLocation(latitude: lat, longitude: lon)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(locationB) { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            }

        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        print("Failed with Error")
    }

    
}
